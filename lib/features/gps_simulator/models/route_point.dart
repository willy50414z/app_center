import 'package:latlong2/latlong.dart';

class RoutePoint {
  const RoutePoint({
    required this.latLng,
    required this.distanceFromStart,
  });

  final LatLng latLng;
  final double distanceFromStart;
}
