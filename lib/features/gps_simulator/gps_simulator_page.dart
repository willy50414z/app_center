import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'models/simulation_state.dart';
import 'services/gps_mock_channel.dart';
import 'services/route_interpolator.dart';
import 'widgets/playback_controls.dart';
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
  final _channel = GpsMockChannel();

  SimulationState _state = const SimulationState();
  List<LatLng> _marks = [];
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

  void _onMark() {
    final center = _mapController.camera.center;
    setState(() {
      _marks.add(center);
      _state = const SimulationState(status: SimulationStatus.ready);
    });
  }

  void _onClearAll() {
    setState(() {
      _marks.clear();
      _interpolatedPoints.clear();
      _state = const SimulationState();
      _currentPosition = null;
    });
  }

  void _onSpeedChanged(int speedKmh) {
    setState(() {
      _state = _state.copyWith(walkingSpeedKmh: speedKmh);
    });
  }

  Future<void> _onTeleport() async {
    if (_marks.isEmpty) return;
    
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('需要位置權限才能使用傳送功能')),
        );
      }
      return;
    }
    
    final target = _marks.last;
    await _channel.teleport(target);
    setState(() {
      _state = SimulationState(status: SimulationStatus.teleporting);
      _currentPosition = target;
    });
  }

  Future<void> _onWalk() async {
    if (_marks.length < 2) return;
    final path = RouteInterpolator.generateWalkingPath(_marks);
    if (path.isEmpty) return;
    final intervalMs = RouteInterpolator.computeWalkingIntervalMs(_state.walkingSpeedKmh);
    await _channel.start(points: path, intervalMs: intervalMs);
    setState(() {
      _interpolatedPoints = path;
      _state = SimulationState(
        status: SimulationStatus.playing,
        totalPoints: path.length,
      );
    });
  }

  Future<void> _onStop() async {
    await _channel.stop();
    setState(() {
      _state = const SimulationState(status: SimulationStatus.ready);
      _interpolatedPoints.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_showSetupGuide) SetupGuideCard(onDismiss: _dismissSetupGuide),
        Expanded(
          child: SimulatorMap(
            mapController: _mapController,
            waypoints: _marks,
            currentPosition: _currentPosition,
            isPlaying: _state.isMoving,
          ),
        ),
        PlaybackControls(
          marks: _marks,
          state: _state,
          onMark: _onMark,
          onClearAll: _onClearAll,
          onTeleport: _onTeleport,
          onWalk: _onWalk,
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