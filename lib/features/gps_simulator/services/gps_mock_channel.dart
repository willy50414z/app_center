import 'dart:async';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

class GpsMockProgressEvent {
  const GpsMockProgressEvent({required this.type, this.index, this.total, this.message});

  final String type;
  final int? index;
  final int? total;
  final String? message;

  factory GpsMockProgressEvent.fromMap(Map<dynamic, dynamic> map) {
    return GpsMockProgressEvent(
      type: map['type'] as String,
      index: map['index'] as int?,
      total: map['total'] as int?,
      message: map['message'] as String?,
    );
  }
}

class GpsMockChannel {
  static const _method = MethodChannel('gps_mock/control');
  static const _event = EventChannel('gps_mock/progress');

  Stream<GpsMockProgressEvent>? _progressStream;

  Stream<GpsMockProgressEvent> get progressStream {
    _progressStream ??= _event
        .receiveBroadcastStream()
        .map((e) => GpsMockProgressEvent.fromMap(e as Map));
    return _progressStream!;
  }

  /// 計算基準 interval：依 OSRM 回傳的 duration 與插值後總點數。
  static int computeIntervalMs({
    required int totalPoints,
    required double durationSeconds,
    required int speedMultiplier,
  }) {
    if (totalPoints == 0 || durationSeconds == 0) return 500;
    final baseMs = (durationSeconds * 1000 / totalPoints).round();
    return (baseMs / speedMultiplier).round().clamp(50, 5000);
  }

  Future<void> start({
    required List<LatLng> points,
    required int intervalMs,
  }) async {
    await _method.invokeMethod('start', {
      'points': points.map((p) => [p.latitude, p.longitude]).toList(),
      'intervalMs': intervalMs,
    });
  }

  Future<void> pause() async {
    await _method.invokeMethod('pause');
  }

  Future<void> resume() async {
    await _method.invokeMethod('resume');
  }

  Future<void> stop() async {
    await _method.invokeMethod('stop');
  }
}
