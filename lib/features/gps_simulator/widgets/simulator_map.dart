import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SimulatorMap extends StatelessWidget {
  const SimulatorMap({
    super.key,
    required this.mapController,
    this.origin,
    this.destination,
    this.routePoints,
    this.currentPosition,
    required this.isPlaying,
    required this.onLongPress,
  });

  final MapController mapController;
  final LatLng? origin;
  final LatLng? destination;
  final List<LatLng>? routePoints;
  final LatLng? currentPosition;
  final bool isPlaying;
  final void Function(LatLng) onLongPress;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: const LatLng(23.5, 121.0),
        initialZoom: 7,
        onLongPress: isPlaying ? null : (_, point) => onLongPress(point),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.willy.appcenter.app_center',
        ),
        if (routePoints != null && routePoints!.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints!,
                color: Colors.blue,
                strokeWidth: 4,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (origin != null)
              Marker(
                point: origin!,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: Colors.green, size: 40),
              ),
            if (destination != null)
              Marker(
                point: destination!,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            if (currentPosition != null)
              Marker(
                point: currentPosition!,
                width: 32,
                height: 32,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.navigation, color: Colors.white, size: 20),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
