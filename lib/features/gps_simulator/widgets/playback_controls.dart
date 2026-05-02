import 'package:flutter/material.dart';
import '../models/simulation_state.dart';

class PlaybackControls extends StatelessWidget {
  const PlaybackControls({
    super.key,
    required this.marks,
    required this.state,
    required this.onMark,
    required this.onClearAll,
    required this.onTeleport,
    required this.onWalk,
    required this.onStop,
    required this.onSpeedChanged,
  });

  final List<dynamic> marks;
  final SimulationState state;
  final VoidCallback onMark;
  final VoidCallback onClearAll;
  final VoidCallback onTeleport;
  final VoidCallback onWalk;
  final VoidCallback onStop;
  final ValueChanged<int> onSpeedChanged;

  bool get _isIdle => state.isIdle || state.isReady;
  bool get _isMoving => state.isMoving || state.isTeleporting;
  bool get _canMark => _isIdle;
  bool get _canClearAll => marks.isNotEmpty && _isIdle;
  bool get _canTeleport => marks.isNotEmpty && _isIdle;
  bool get _canWalk => marks.length >= 2 && _isIdle;

  @override
  Widget build(BuildContext context) {
    if (_isMoving) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onStop,
            icon: const Icon(Icons.stop),
            label: const Text('停止'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SpeedControl(
          speedKmh: state.walkingSpeedKmh,
          onChanged: onSpeedChanged,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ActionButton(
              icon: Icons.add_location,
              label: '標記',
              onPressed: _canMark ? onMark : null,
            ),
            _ActionButton(
              icon: Icons.clear_all,
              label: '清除全部',
              onPressed: _canClearAll ? onClearAll : null,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ActionButton(
              icon: Icons.arrow_forward,
              label: '傳送',
              onPressed: _canTeleport ? onTeleport : null,
              color: Colors.purple,
            ),
            _ActionButton(
              icon: Icons.directions_walk,
              label: '走路',
              onPressed: _canWalk ? onWalk : null,
              color: Colors.green,
            ),
          ],
        ),
      ],
    );
  }
}

class _SpeedControl extends StatelessWidget {
  const _SpeedControl({required this.speedKmh, required this.onChanged});

  final int speedKmh;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_walk, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: speedKmh > 1 ? () => onChanged(speedKmh - 1) : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          SizedBox(
            width: 72,
            child: Text(
              '$speedKmh km/h',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: speedKmh < 20 ? () => onChanged(speedKmh + 1) : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          iconSize: 40,
          icon: Icon(icon, color: enabled ? (color ?? Colors.blue) : Colors.grey),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: enabled ? Colors.black87 : Colors.grey,
          ),
        ),
      ],
    );
  }
}
