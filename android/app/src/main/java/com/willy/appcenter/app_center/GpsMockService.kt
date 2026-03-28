package com.willy.appcenter.app_center

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.location.Criteria
import android.location.Location
import android.location.LocationManager
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.SystemClock
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.EventChannel

class GpsMockService : Service() {

    companion object {
        const val CHANNEL_ID = "gps_mock_channel"
        const val NOTIFICATION_ID = 1001
        const val EXTRA_LATITUDES = "latitudes"
        const val EXTRA_LONGITUDES = "longitudes"
        const val EXTRA_INTERVAL_MS = "interval_ms"

        var eventSink: EventChannel.EventSink? = null
        var instance: GpsMockService? = null
    }

    private var locationManager: LocationManager? = null
    private var handler: Handler? = null
    private var points: List<Pair<Double, Double>> = emptyList()
    private var currentIndex = 0
    private var intervalMs = 500L
    private var isPaused = false

    private val runnable = object : Runnable {
        override fun run() {
            if (isPaused) return
            if (currentIndex >= points.size) {
                sendEvent(mapOf("type" to "completed"))
                stopSelf()
                return
            }
            val (lat, lng) = points[currentIndex]
            injectLocation(lat, lng)
            sendEvent(mapOf("type" to "progress", "index" to currentIndex, "total" to points.size))
            currentIndex++
            handler?.postDelayed(this, intervalMs)
        }
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        locationManager = getSystemService(LOCATION_SERVICE) as LocationManager
        handler = Handler(Looper.getMainLooper())
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val latArray = intent?.getDoubleArrayExtra(EXTRA_LATITUDES) ?: return START_NOT_STICKY
        val lngArray = intent.getDoubleArrayExtra(EXTRA_LONGITUDES) ?: return START_NOT_STICKY
        intervalMs = intent.getLongExtra(EXTRA_INTERVAL_MS, 500L)

        points = latArray.zip(lngArray.toList())
        currentIndex = 0
        isPaused = false

        try {
            setupTestProvider()
        } catch (e: SecurityException) {
            sendEvent(mapOf("type" to "error", "message" to "請先在開發人員選項中將 App Center 設為模擬位置應用程式"))
            stopSelf()
            return START_NOT_STICKY
        }

        startForeground(NOTIFICATION_ID, buildNotification("GPS 模擬中"))
        handler?.post(runnable)
        return START_NOT_STICKY
    }

    fun pause() {
        isPaused = true
        handler?.removeCallbacks(runnable)
    }

    fun resume() {
        if (!isPaused) return
        isPaused = false
        handler?.post(runnable)
    }

    fun stop() {
        handler?.removeCallbacks(runnable)
        removeTestProvider()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun setupTestProvider() {
        val lm = locationManager ?: return
        if (lm.allProviders.contains(LocationManager.GPS_PROVIDER)) {
            try { lm.removeTestProvider(LocationManager.GPS_PROVIDER) } catch (_: Exception) {}
        }
        lm.addTestProvider(
            LocationManager.GPS_PROVIDER,
            false, false, false, false, true, true, true,
            Criteria.POWER_LOW, Criteria.ACCURACY_FINE
        )
        lm.setTestProviderEnabled(LocationManager.GPS_PROVIDER, true)
    }

    private fun removeTestProvider() {
        try {
            locationManager?.removeTestProvider(LocationManager.GPS_PROVIDER)
        } catch (_: Exception) {}
    }

    private fun injectLocation(lat: Double, lng: Double) {
        val lm = locationManager ?: return
        val location = Location(LocationManager.GPS_PROVIDER).apply {
            latitude = lat
            longitude = lng
            altitude = 0.0
            accuracy = 1.0f
            time = System.currentTimeMillis()
            elapsedRealtimeNanos = SystemClock.elapsedRealtimeNanos()
        }
        try {
            lm.setTestProviderLocation(LocationManager.GPS_PROVIDER, location)
        } catch (_: Exception) {}
    }

    private fun sendEvent(data: Map<String, Any>) {
        handler?.post {
            eventSink?.success(data)
        }
    }

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "GPS 模擬",
            NotificationManager.IMPORTANCE_LOW
        ).apply { description = "GPS 路線模擬器運作中" }
        val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        nm.createNotificationChannel(channel)
    }

    private fun buildNotification(text: String): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("GPS 模擬中")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setOngoing(true)
            .build()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        handler?.removeCallbacks(runnable)
        removeTestProvider()
        instance = null
        super.onDestroy()
    }
}
