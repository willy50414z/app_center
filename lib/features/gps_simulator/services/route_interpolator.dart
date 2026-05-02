import 'dart:math';
import 'package:latlong2/latlong.dart';

class RouteInterpolator {
  static const _earthRadiusMeters = 6371000.0;

  /// 在每對相鄰點之間插入中間點，使相鄰點間距 ≤ [maxSegmentMeters]。
  static List<LatLng> interpolate(
    List<LatLng> sparse, {
    double maxSegmentMeters = 15,
  }) {
    if (sparse.length < 2) return List.of(sparse);

    final result = <LatLng>[sparse.first];

    for (var i = 0; i < sparse.length - 1; i++) {
      final a = sparse[i];
      final b = sparse[i + 1];
      final dist = _haversineMeters(a, b);

      if (dist > maxSegmentMeters) {
        final steps = (dist / maxSegmentMeters).ceil();
        for (var s = 1; s < steps; s++) {
          final t = s / steps;
          result.add(LatLng(
            a.latitude + (b.latitude - a.latitude) * t,
            a.longitude + (b.longitude - a.longitude) * t,
          ));
        }
      }

      result.add(b);
    }

    return result;
  }

  static double _haversineMeters(LatLng a, LatLng b) {
    final lat1 = a.latitude * pi / 180;
    final lat2 = b.latitude * pi / 180;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLon = (b.longitude - a.longitude) * pi / 180;

    final sinLat = sin(dLat / 2);
    final sinLon = sin(dLon / 2);

    final h = sinLat * sinLat + cos(lat1) * cos(lat2) * sinLon * sinLon;
    return 2 * _earthRadiusMeters * asin(sqrt(h));
  }

  static const _walkingSpeedMs = 1.4;

  static List<LatLng> generateWalkingPath(List<LatLng> waypoints) {
    if (waypoints.length < 2) return [];

    final controlPoints = <LatLng>[];

    for (var i = 0; i < waypoints.length - 1; i++) {
      final a = waypoints[i];
      final b = waypoints[i + 1];
      final dist = _haversineMeters(a, b);

      final dLat = b.latitude - a.latitude;
      final dLon = b.longitude - a.longitude;
      final len = sqrt(dLat * dLat + dLon * dLon);
      if (len == 0) continue;

      final dirLat = dLat / len;
      final dirLon = dLon / len;
      final perpLat = -dirLon;
      final perpLon = dirLat;

      const segmentSpacingMeters = 25.0;
      final numSegments = (dist / segmentSpacingMeters).ceil() + 1;
      final random = Random();
      final seed = random.nextInt(10000);

      for (var s = 0; s < numSegments; s++) {
        final t = s / (numSegments - 1);
        final baseLat = a.latitude + dLat * t;
        final baseLng = a.longitude + dLon * t;

        final offsetMeters = (seed + s * 7) % 10000 / 1000.0 - 5.0;
        final clampedOffset = offsetMeters.clamp(-8.0, 8.0);
        final offsetLat = perpLat * clampedOffset / _earthRadiusMeters * 180 / pi;
        final offsetLng = perpLon * clampedOffset / _earthRadiusMeters * 180 / pi;

        controlPoints.add(LatLng(baseLat + offsetLat, baseLng + offsetLng));
      }
    }

    controlPoints.add(waypoints.last);
    return interpolate(controlPoints, maxSegmentMeters: 5);
  }

  static int computeWalkingIntervalMs(int speedKmh) {
    final speedMs = speedKmh / 3.6;
    return (5.0 / speedMs * 1000).round();
  }
}
