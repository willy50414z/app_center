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
