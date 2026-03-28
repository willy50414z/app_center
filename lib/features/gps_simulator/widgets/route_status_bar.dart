import 'package:flutter/material.dart';
import '../models/simulation_state.dart';

class RouteStatusBar extends StatelessWidget {
  const RouteStatusBar({super.key, required this.state});

  final SimulationState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == SimulationStatus.routing) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 8),
            Text('正在計算路線...'),
          ],
        ),
      );
    }

    if (state.routeDistanceKm == null) return const SizedBox.shrink();

    final distText = state.routeDistanceKm! < 1
        ? '${(state.routeDistanceKm! * 1000).round()} m'
        : '${state.routeDistanceKm!.toStringAsFixed(1)} km';

    final dur = state.routeDurationSec ?? 0;
    final durText = dur < 60
        ? '${dur.round()} 秒'
        : '${(dur / 60).round()} 分鐘';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.straighten, size: 16),
          const SizedBox(width: 4),
          Text(distText),
          const SizedBox(width: 16),
          const Icon(Icons.access_time, size: 16),
          const SizedBox(width: 4),
          Text(durText),
        ],
      ),
    );
  }
}
