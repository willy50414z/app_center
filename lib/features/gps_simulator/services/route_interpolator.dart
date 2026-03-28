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
}
