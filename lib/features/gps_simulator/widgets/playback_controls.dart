import 'package:flutter/material.dart';
import '../models/simulation_state.dart';

class PlaybackControls extends StatelessWidget {
  const PlaybackControls({
    super.key,
    required this.state,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
    required this.onSpeedChanged,
  });

  final SimulationState state;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final void Function(int multiplier) onSpeedChanged;

  bool get _canPlay =>
      state.status == SimulationStatus.ready ||
      state.status == SimulationStatus.paused;

  bool get _canStop =>
      state.status == SimulationStatus.playing ||
      state.status == SimulationStatus.paused;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_canStop || state.status == SimulationStatus.playing)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: state.progress,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 48,
              icon: Icon(
                state.status == SimulationStatus.playing
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: _canPlay || state.status == SimulationStatus.playing
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              onPressed: state.status == SimulationStatus.playing
                  ? onPause
                  : _canPlay
                      ? onPlay
                      : null,
            ),
            IconButton(
              iconSize: 40,
              icon: Icon(
                Icons.stop_circle,
                color: _canStop ? Colors.redAccent : Colors.grey,
              ),
              onPressed: _canStop ? onStop : null,
            ),
            const SizedBox(width: 8),
            _SpeedSelector(
              current: state.speedMultiplier,
              onChanged: onSpeedChanged,
            ),
          ],
        ),
      ],
    );
  }
}

class _SpeedSelector extends StatelessWidget {
  const _SpeedSelector({required this.current, required this.onChanged});

  final int current;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(value: 1, label: Text('1x')),
        ButtonSegment(value: 2, label: Text('2x')),
        ButtonSegment(value: 5, label: Text('5x')),
      ],
      selected: {current},
      onSelectionChanged: (s) => onChanged(s.first),
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
