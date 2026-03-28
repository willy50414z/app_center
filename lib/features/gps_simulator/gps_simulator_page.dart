import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/simulation_state.dart';
import 'services/gps_mock_channel.dart';
import 'services/osrm_service.dart';
import 'services/route_interpolator.dart';
import 'widgets/playback_controls.dart';
import 'widgets/route_status_bar.dart';
import 'widgets/setup_guide_card.dart';
import 'widgets/simulator_map.dart';

const _setupDoneKey = 'gps_simulator_setup_done';

class GpsSimulatorPage extends StatefulWidget {
  const GpsSimulatorPage({super.key});

  @override
  State<GpsSimulatorPage> createState() => _GpsSimulatorPageState();
}

class _GpsSimulatorPageState extends State<GpsSimulatorPage> {
  final _mapController = MapController();
  final _osrm = OsrmService();
  final _channel = GpsMockChannel();

  SimulationState _state = const SimulationState();
  LatLng? _origin;
  LatLng? _destination;
  List<LatLng> _interpolatedPoints = [];
  LatLng? _currentPosition;

  StreamSubscription<GpsMockProgressEvent>? _progressSub;
  bool _showSetupGuide = false;

  @override
  void initState() {
    super.initState();
    _checkSetupGuide();
    _listenProgress();
  }

  Future<void> _checkSetupGuide() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(_setupDoneKey) ?? false;
    if (!done && mounted) {
      setState(() => _showSetupGuide = true);
    }
  }

  Future<void> _dismissSetupGuide() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_setupDoneKey, true);
    if (mounted) setState(() => _showSetupGuide = false);
  }

  void _listenProgress() {
    _progressSub = _channel.progressStream.listen((event) {
      if (!mounted) return;
      switch (event.type) {
        case 'progress':
          final idx = event.index ?? 0;
          setState(() {
            _state = _state.copyWith(
              currentIndex: idx,
              status: SimulationStatus.playing,
            );
            if (idx < _interpolatedPoints.length) {
              _currentPosition = _interpolatedPoints[idx];
            }
          });
        case 'completed':
          setState(() {
            _state = const SimulationState(status: SimulationStatus.ready);
            _currentPosition = _origin;
          });
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('模擬完成')));
          }
        case 'error':
          final msg = event.message ?? '發生未知錯誤';
          setState(() => _state = _state.copyWith(
                status: SimulationStatus.ready,
                errorMessage: msg,
              ));
          if (mounted) _showErrorWithGuide(msg);
      }
    });
  }

  void _showErrorWithGuide(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        action: SnackBarAction(
          label: '查看設定步驟',
          onPressed: () => setState(() => _showSetupGuide = true),
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  // ── 長按地圖 ──────────────────────────────────────────────

  void _onMapLongPress(LatLng point) {
    if (_origin == null) {
      _setOrigin(point);
    } else if (_destination == null) {
      _setDestination(point);
    } else {
      _showPointSelectionSheet(point);
    }
  }

  void _setOrigin(LatLng point) {
    setState(() {
      _origin = point;
      _destination = null;
      _interpolatedPoints = [];
      _state = const SimulationState();
      _currentPosition = null;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('起點已設定'), duration: Duration(seconds: 1)));
  }

  void _setDestination(LatLng point) {
    setState(() => _destination = point);
    _fetchRoute();
  }

  void _showPointSelectionSheet(LatLng point) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.green),
              title: const Text('設為新起點'),
              onTap: () {
                Navigator.pop(context);
                _setOrigin(point);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: const Text('設為新終點'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _destination = point);
                _fetchRoute();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── 路線計算 ──────────────────────────────────────────────

  Future<void> _fetchRoute() async {
    final origin = _origin;
    final destination = _destination;
    if (origin == null || destination == null) return;

    setState(() => _state = _state.copyWith(status: SimulationStatus.routing));

    try {
      final result = await _osrm.fetchRoute(origin, destination);
      final dense = RouteInterpolator.interpolate(result.points);

      setState(() {
        _interpolatedPoints = dense;
        _currentPosition = origin;
        _state = SimulationState(
          status: SimulationStatus.ready,
          totalPoints: dense.length,
          routeDistanceKm: result.distanceMeters / 1000,
          routeDurationSec: result.durationSeconds,
        );
      });

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(result.points),
          padding: const EdgeInsets.all(40),
        ),
      );
    } on OsrmException catch (e) {
      setState(() => _state = _state.copyWith(
            status: SimulationStatus.idle,
            errorMessage: e.message,
          ));
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  // ── 播放控制 ──────────────────────────────────────────────

  Future<void> _onPlay() async {
    final intervalMs = GpsMockChannel.computeIntervalMs(
      totalPoints: _interpolatedPoints.length,
      durationSeconds: _state.routeDurationSec ?? 0,
      speedMultiplier: _state.speedMultiplier,
    );
    await _channel.start(points: _interpolatedPoints, intervalMs: intervalMs);
    setState(() => _state = _state.copyWith(status: SimulationStatus.playing));
  }

  Future<void> _onPause() async {
    await _channel.pause();
    setState(() => _state = _state.copyWith(status: SimulationStatus.paused));
  }

  Future<void> _onStop() async {
    await _channel.stop();
    setState(() {
      _state = SimulationState(
        status: SimulationStatus.ready,
        totalPoints: _interpolatedPoints.length,
        routeDistanceKm: _state.routeDistanceKm,
        routeDurationSec: _state.routeDurationSec,
        speedMultiplier: _state.speedMultiplier,
      );
      _currentPosition = _origin;
    });
  }

  void _onSpeedChanged(int multiplier) {
    setState(() => _state = _state.copyWith(speedMultiplier: multiplier));
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_showSetupGuide) SetupGuideCard(onDismiss: _dismissSetupGuide),
        Expanded(
          child: SimulatorMap(
            mapController: _mapController,
            origin: _origin,
            destination: _destination,
            routePoints: _interpolatedPoints.isNotEmpty ? _interpolatedPoints : null,
            currentPosition: _currentPosition,
            isPlaying: _state.status == SimulationStatus.playing,
            onLongPress: _onMapLongPress,
          ),
        ),
        RouteStatusBar(state: _state),
        PlaybackControls(
          state: _state,
          onPlay: _onPlay,
          onPause: _onPause,
          onStop: _onStop,
          onSpeedChanged: _onSpeedChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  void dispose() {
    _progressSub?.cancel();
    _mapController.dispose();
    super.dispose();
  }
}
