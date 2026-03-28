import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OsrmException implements Exception {
  OsrmException(this.message);
  final String message;
  @override
  String toString() => message;
}

class OsrmRouteResult {
  const OsrmRouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
}

class OsrmService {
  static const _baseUrl = 'router.project-osrm.org';

  Future<OsrmRouteResult> fetchRoute(LatLng origin, LatLng destination) async {
    final uri = Uri.https(
      _baseUrl,
      '/route/v1/driving/'
          '${origin.longitude},${origin.latitude};'
          '${destination.longitude},${destination.latitude}',
      {'overview': 'full', 'geometries': 'geojson'},
    );

    final http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 15));
    } catch (e) {
      throw OsrmException('無法取得路線，請檢查網路連線後重試');
    }

    if (response.statusCode != 200) {
      throw OsrmException('無法取得路線，請檢查網路連線後重試');
    }

    final Map<String, dynamic> body;
    try {
      body = json.decode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw OsrmException('路線資料解析失敗，請稍後重試');
    }

    if (body['code'] != 'Ok') {
      throw OsrmException('找不到可行路線，請確認起訖點位置');
    }

    final routes = body['routes'] as List<dynamic>;
    if (routes.isEmpty) throw OsrmException('找不到可行路線，請確認起訖點位置');

    final route = routes[0] as Map<String, dynamic>;
    final distanceMeters = (route['distance'] as num).toDouble();
    final durationSeconds = (route['duration'] as num).toDouble();

    final geometry = route['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;

    final points = coordinates.map((c) {
      final coord = c as List<dynamic>;
      return LatLng(
        (coord[1] as num).toDouble(),
        (coord[0] as num).toDouble(),
      );
    }).toList();

    return OsrmRouteResult(
      points: points,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
    );
  }
}
