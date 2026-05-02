import 'package:flutter_test/flutter_test.dart';
import 'package:app_center/features/gps_simulator/services/route_interpolator.dart';

void main() {
  group('RouteInterpolator.computeWalkingIntervalMs', () {
    test('5 km/h gives ~3600 ms for 5m segment', () {
      // 5 km/h = 1.3888 m/s, 5m / 1.3888 m/s * 1000 = 3600ms
      final result = RouteInterpolator.computeWalkingIntervalMs(5);
      expect(result, closeTo(3600, 50));
    });

    test('10 km/h gives ~1800 ms for 5m segment', () {
      // 10 km/h = 2.7777 m/s, 5m / 2.7777 * 1000 = 1800ms
      final result = RouteInterpolator.computeWalkingIntervalMs(10);
      expect(result, closeTo(1800, 50));
    });

    test('1 km/h gives ~18000 ms for 5m segment', () {
      final result = RouteInterpolator.computeWalkingIntervalMs(1);
      expect(result, closeTo(18000, 100));
    });

    test('20 km/h gives ~900 ms for 5m segment', () {
      // 20 km/h = 5.5555 m/s, 5m / 5.5555 * 1000 = 900ms
      final result = RouteInterpolator.computeWalkingIntervalMs(20);
      expect(result, closeTo(900, 20));
    });
  });
}
