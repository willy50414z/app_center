# Walking Speed Control Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a km/h speed input (with +/- buttons) at the top of PlaybackControls so the user can set walking speed before starting simulation.

**Architecture:** Replace the unused `speedMultiplier` field in `SimulationState` with `walkingSpeedKmh: int`. Pass this value from the page through `PlaybackControls` into `RouteInterpolator.computeWalkingIntervalMs()`. Speed is set before walking starts; changing it mid-walk has no effect until the next walk.

**Tech Stack:** Flutter/Dart, existing project structure under `lib/features/gps_simulator/`

---

## File Map

| File | Change |
|------|--------|
| `lib/features/gps_simulator/models/simulation_state.dart` | Replace `speedMultiplier` → `walkingSpeedKmh` |
| `lib/features/gps_simulator/services/route_interpolator.dart` | `computeWalkingIntervalMs()` accepts `int speedKmh` |
| `lib/features/gps_simulator/widgets/playback_controls.dart` | Add speed row + `onSpeedChanged` callback |
| `lib/features/gps_simulator/gps_simulator_page.dart` | Track speed in state, wire callback, pass to `_onWalk()` |
| `test/route_interpolator_test.dart` | Unit tests for interval calculation |

---

### Task 1: Update SimulationState

**Files:**
- Modify: `lib/features/gps_simulator/models/simulation_state.dart`

- [ ] **Step 1: Replace `speedMultiplier` with `walkingSpeedKmh`**

Replace the entire file content:

```dart
enum SimulationStatus { idle, routing, ready, playing, paused, teleporting }

class SimulationState {
  const SimulationState({
    this.status = SimulationStatus.idle,
    this.currentIndex = 0,
    this.totalPoints = 0,
    this.walkingSpeedKmh = 5,
    this.routeDistanceKm,
    this.routeDurationSec,
    this.errorMessage,
  });

  final SimulationStatus status;
  final int currentIndex;
  final int totalPoints;
  final int walkingSpeedKmh;
  final double? routeDistanceKm;
  final double? routeDurationSec;
  final String? errorMessage;

  double get progress =>
      totalPoints == 0 ? 0 : currentIndex / totalPoints;

  bool get isIdle => status == SimulationStatus.idle;
  bool get isReady => status == SimulationStatus.ready;
  bool get isPlaying => status == SimulationStatus.playing;
  bool get isPaused => status == SimulationStatus.paused;
  bool get isTeleporting => status == SimulationStatus.teleporting;
  bool get isMoving => isPlaying;

  SimulationState copyWith({
    SimulationStatus? status,
    int? currentIndex,
    int? totalPoints,
    int? walkingSpeedKmh,
    double? routeDistanceKm,
    double? routeDurationSec,
    String? errorMessage,
  }) {
    return SimulationState(
      status: status ?? this.status,
      currentIndex: currentIndex ?? this.currentIndex,
      totalPoints: totalPoints ?? this.totalPoints,
      walkingSpeedKmh: walkingSpeedKmh ?? this.walkingSpeedKmh,
      routeDistanceKm: routeDistanceKm ?? this.routeDistanceKm,
      routeDurationSec: routeDurationSec ?? this.routeDurationSec,
      errorMessage: errorMessage,
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/gps_simulator/models/simulation_state.dart
git commit -m "refactor: replace speedMultiplier with walkingSpeedKmh in SimulationState"
```

---

### Task 2: Update RouteInterpolator + unit tests

**Files:**
- Modify: `lib/features/gps_simulator/services/route_interpolator.dart`
- Create: `test/route_interpolator_test.dart`

- [ ] **Step 1: Write failing unit test**

Create `test/route_interpolator_test.dart`:

```dart
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
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/route_interpolator_test.dart
```

Expected: FAIL — `computeWalkingIntervalMs` takes no arguments.

- [ ] **Step 3: Update `computeWalkingIntervalMs` to accept speed**

In `lib/features/gps_simulator/services/route_interpolator.dart`, replace:

```dart
  static int computeWalkingIntervalMs() {
    return (5.0 / _walkingSpeedMs * 1000).round();
  }
```

With:

```dart
  static int computeWalkingIntervalMs(int speedKmh) {
    final speedMs = speedKmh / 3.6;
    return (5.0 / speedMs * 1000).round();
  }
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/route_interpolator_test.dart
```

Expected: All 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/gps_simulator/services/route_interpolator.dart test/route_interpolator_test.dart
git commit -m "feat: computeWalkingIntervalMs accepts speedKmh parameter"
```

---

### Task 3: Add speed control UI to PlaybackControls

**Files:**
- Modify: `lib/features/gps_simulator/widgets/playback_controls.dart`

- [ ] **Step 1: Add `walkingSpeedKmh` and `onSpeedChanged` to widget**

Replace the entire file content:

```dart
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/gps_simulator/widgets/playback_controls.dart
git commit -m "feat: add speed control row to PlaybackControls"
```

---

### Task 4: Wire speed in GpsSimulatorPage

**Files:**
- Modify: `lib/features/gps_simulator/gps_simulator_page.dart`

- [ ] **Step 1: Add `_onSpeedChanged` handler and wire to `_onWalk`**

In `_GpsSimulatorPageState`, add the handler method after `_onClearAll`:

```dart
  void _onSpeedChanged(int speedKmh) {
    setState(() {
      _state = _state.copyWith(walkingSpeedKmh: speedKmh);
    });
  }
```

- [ ] **Step 2: Pass speed to `computeWalkingIntervalMs` in `_onWalk`**

Replace:

```dart
    final intervalMs = RouteInterpolator.computeWalkingIntervalMs();
```

With:

```dart
    final intervalMs = RouteInterpolator.computeWalkingIntervalMs(_state.walkingSpeedKmh);
```

- [ ] **Step 3: Pass `onSpeedChanged` to `PlaybackControls`**

In the `build` method, add `onSpeedChanged: _onSpeedChanged` to `PlaybackControls`:

```dart
        PlaybackControls(
          marks: _marks,
          state: _state,
          onMark: _onMark,
          onClearAll: _onClearAll,
          onTeleport: _onTeleport,
          onWalk: _onWalk,
          onStop: _onStop,
          onSpeedChanged: _onSpeedChanged,
        ),
```

- [ ] **Step 4: Run full test suite**

```bash
flutter test
```

Expected: All tests PASS (including route_interpolator_test.dart).

- [ ] **Step 5: Commit**

```bash
git add lib/features/gps_simulator/gps_simulator_page.dart
git commit -m "feat: wire walking speed control to simulation page"
```
