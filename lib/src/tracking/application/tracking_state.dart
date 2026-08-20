import '../domain/tracking_route_point.dart';

enum TrackingStatus { stopped, running, paused }

class TrackingState {
  TrackingState({
    required this.status,
    required this.startedAt,
    required this.elapsedDuration,
    required this.activeStartedAt,
    required List<TrackingRoutePoint> routePoints,
    required this.distanceMeters,
  }) : routePoints = List.unmodifiable(routePoints);

  factory TrackingState.stopped() {
    return TrackingState(
      status: TrackingStatus.stopped,
      startedAt: null,
      elapsedDuration: Duration.zero,
      activeStartedAt: null,
      routePoints: const [],
      distanceMeters: 0,
    );
  }

  final TrackingStatus status;
  final DateTime? startedAt;
  final Duration elapsedDuration;
  final DateTime? activeStartedAt;
  final List<TrackingRoutePoint> routePoints;
  final double distanceMeters;

  bool get isStopped => status == TrackingStatus.stopped;

  bool get isRunning => status == TrackingStatus.running;

  bool get isPaused => status == TrackingStatus.paused;

  Duration elapsedAt(DateTime timestamp) {
    if (!isRunning || activeStartedAt == null) {
      return elapsedDuration;
    }

    final activeDelta = timestamp.difference(activeStartedAt!);
    if (activeDelta.isNegative) {
      return elapsedDuration;
    }

    return elapsedDuration + activeDelta;
  }
}
