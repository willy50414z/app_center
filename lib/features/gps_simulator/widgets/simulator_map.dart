import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SimulatorMap extends StatelessWidget {
  const SimulatorMap({
    super.key,
    required this.mapController,
    this.waypoints,
    this.currentPosition,
    this.isPlaying = false,
  });

  final MapController mapController;
  final List<LatLng>? waypoints;
  final LatLng? currentPosition;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: const LatLng(23.5, 121.0),
            initialZoom: 7,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.willy.appcenter.app_center',
            ),
            MarkerLayer(
              markers: [
                if (waypoints != null)
                  ...waypoints!.asMap().entries.map((e) => Marker(
                        point: e.value,
                        width: 32,
                        height: 32,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '${e.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )),
                if (currentPosition != null)
                  Marker(
                    point: currentPosition!,
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.navigation, color: Colors.white, size: 14),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const Center(
          child: Icon(
            Icons.add,
            size: 40,
            color: Colors.black54,
          ),
        ),
        const Center(
          child: Icon(
            Icons.remove,
            size: 40,
            color: Colors.black54,
          ),
        ),
        const Center(
          child: Icon(
            Icons.circle,
            size: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}