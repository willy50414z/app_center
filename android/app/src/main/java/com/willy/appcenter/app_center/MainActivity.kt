package com.willy.appcenter.app_center

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var gpsMockService: GpsMockService? = null
    private var serviceConnection: android.content.ServiceConnection? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "gps_mock/progress")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    GpsMockService.eventSink = events
                }
                override fun onCancel(arguments: Any?) {
                    GpsMockService.eventSink = null
                }
            })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "gps_mock/control")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        val points = call.argument<List<List<Double>>>("points") ?: emptyList()
                        val intervalMs = (call.argument<Int>("intervalMs") ?: 500).toLong()

                        val latitudes = points.map { it[0] }.toDoubleArray()
                        val longitudes = points.map { it[1] }.toDoubleArray()

                        val intent = Intent(this, GpsMockService::class.java).apply {
                            putExtra(GpsMockService.EXTRA_LATITUDES, latitudes)
                            putExtra(GpsMockService.EXTRA_LONGITUDES, longitudes)
                            putExtra(GpsMockService.EXTRA_INTERVAL_MS, intervalMs)
                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(null)
                    }
                    "pause" -> {
                        GpsMockService.instance?.pause()
                        result.success(null)
                    }
                    "resume" -> {
                        GpsMockService.instance?.resume()
                        result.success(null)
                    }
                    "stop" -> {
                        GpsMockService.instance?.stop()
                            ?: stopService(Intent(this, GpsMockService::class.java))
                        result.success(null)
                    }
                    "teleport" -> {
                        val lat = call.argument<Double>("lat") ?: run {
                            result.error("INVALID_ARGUMENT", "lat is required", null)
                            return@setMethodCallHandler
                        }
                        val lng = call.argument<Double>("lng") ?: run {
                            result.error("INVALID_ARGUMENT", "lng is required", null)
                            return@setMethodCallHandler
                        }

                        val intent = Intent(this, GpsMockService::class.java).apply {
                            putExtra(GpsMockService.EXTRA_LATITUDES, doubleArrayOf(lat))
                            putExtra(GpsMockService.EXTRA_LONGITUDES, doubleArrayOf(lng))
                            putExtra(GpsMockService.EXTRA_MODE, GpsMockService.MODE_TELEPORT)
                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
