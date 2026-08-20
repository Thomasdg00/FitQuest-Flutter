import '../domain/distance_calculator.dart';
import '../domain/tracking_route_point.dart';
import 'finalized_tracking_session.dart';
import 'tracking_state.dart';

class TrackingController {
  TrackingController({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      state = TrackingState.stopped();

  final DateTime Function() _clock;

  TrackingState state;
  FinalizedTrackingSession? lastFinalizedSession;

  void start({DateTime? at}) {
    if (!state.isStopped) {
      return;
    }

    final timestamp = _timestamp(at);
    lastFinalizedSession = null;
    state = TrackingState(
      status: TrackingStatus.running,
      startedAt: timestamp,
      elapsedDuration: Duration.zero,
      activeStartedAt: timestamp,
      routePoints: const [],
      distanceMeters: 0,
    );
  }

  void pause({DateTime? at}) {
    if (!state.isRunning) {
      return;
    }

    final timestamp = _timestamp(at);
    state = TrackingState(
      status: TrackingStatus.paused,
      startedAt: state.startedAt,
      elapsedDuration: state.elapsedAt(timestamp),
      activeStartedAt: null,
      routePoints: state.routePoints,
      distanceMeters: state.distanceMeters,
    );
  }

  void resume({DateTime? at}) {
    if (!state.isPaused) {
      return;
    }

    final timestamp = _timestamp(at);
    state = TrackingState(
      status: TrackingStatus.running,
      startedAt: state.startedAt,
      elapsedDuration: state.elapsedDuration,
      activeStartedAt: timestamp,
      routePoints: state.routePoints,
      distanceMeters: state.distanceMeters,
    );
  }

  FinalizedTrackingSession? stop({DateTime? at}) {
    if (state.isStopped || state.startedAt == null) {
      return null;
    }

    final timestamp = _timestamp(at);
    final duration = state.isRunning
        ? state.elapsedAt(timestamp)
        : state.elapsedDuration;

    final session = FinalizedTrackingSession(
      startedAt: state.startedAt!,
      endedAt: timestamp,
      duration: duration,
      distanceMeters: state.distanceMeters,
      routePoints: state.routePoints,
    );

    lastFinalizedSession = session;
    state = TrackingState.stopped();
    return session;
  }

  bool recordPoint({
    required double latitude,
    required double longitude,
    DateTime? at,
  }) {
    if (!state.isRunning ||
        !DistanceCalculator.isValidCoordinate(latitude, longitude)) {
      return false;
    }

    final timestamp = _timestamp(at);
    final point = TrackingRoutePoint(
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
    );

    final existingPoints = state.routePoints;
    if (existingPoints.isNotEmpty &&
        _isSamePosition(existingPoints.last, point)) {
      return false;
    }

    final distanceDelta = existingPoints.isEmpty
        ? 0.0
        : DistanceCalculator.metersBetween(
            startLatitude: existingPoints.last.latitude,
            startLongitude: existingPoints.last.longitude,
            endLatitude: point.latitude,
            endLongitude: point.longitude,
          );

    state = TrackingState(
      status: state.status,
      startedAt: state.startedAt,
      elapsedDuration: state.elapsedDuration,
      activeStartedAt: state.activeStartedAt,
      routePoints: [...existingPoints, point],
      distanceMeters: state.distanceMeters + distanceDelta,
    );
    return true;
  }

  Duration elapsedAt(DateTime? at) {
    return state.elapsedAt(_timestamp(at));
  }

  DateTime _timestamp(DateTime? at) {
    return (at ?? _clock()).toUtc();
  }

  bool _isSamePosition(TrackingRoutePoint first, TrackingRoutePoint second) {
    return first.latitude == second.latitude &&
        first.longitude == second.longitude;
  }
}
