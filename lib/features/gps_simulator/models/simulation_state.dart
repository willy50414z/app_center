enum SimulationStatus { idle, routing, ready, playing, paused }

class SimulationState {
  const SimulationState({
    this.status = SimulationStatus.idle,
    this.currentIndex = 0,
    this.totalPoints = 0,
    this.speedMultiplier = 1,
    this.routeDistanceKm,
    this.routeDurationSec,
    this.errorMessage,
  });

  final SimulationStatus status;
  final int currentIndex;
  final int totalPoints;
  final int speedMultiplier;
  final double? routeDistanceKm;
  final double? routeDurationSec;
  final String? errorMessage;

  double get progress =>
      totalPoints == 0 ? 0 : currentIndex / totalPoints;

  SimulationState copyWith({
    SimulationStatus? status,
    int? currentIndex,
    int? totalPoints,
    int? speedMultiplier,
    double? routeDistanceKm,
    double? routeDurationSec,
    String? errorMessage,
  }) {
    return SimulationState(
      status: status ?? this.status,
      currentIndex: currentIndex ?? this.currentIndex,
      totalPoints: totalPoints ?? this.totalPoints,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      routeDistanceKm: routeDistanceKm ?? this.routeDistanceKm,
      routeDurationSec: routeDurationSec ?? this.routeDurationSec,
      errorMessage: errorMessage,
    );
  }
}
