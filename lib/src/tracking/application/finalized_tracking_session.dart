import '../../domain/workout/route_point.dart';
import '../../domain/workout/workout.dart';
import '../../domain/workout/workout_repository.dart';
import '../domain/tracking_route_point.dart';

class FinalizedTrackingSession {
  FinalizedTrackingSession({
    required this.startedAt,
    required this.endedAt,
    required this.duration,
    required this.distanceMeters,
    required List<TrackingRoutePoint> routePoints,
  }) : routePoints = List.unmodifiable(routePoints);

  final DateTime startedAt;
  final DateTime endedAt;
  final Duration duration;
  final double distanceMeters;
  final List<TrackingRoutePoint> routePoints;

  Workout toWorkout() {
    return Workout(
      id: null,
      startedAt: startedAt,
      duration: duration,
      distanceMeters: distanceMeters,
    );
  }

  List<RoutePoint> routePointsForWorkout(int workoutId) {
    return [
      for (final point in routePoints)
        RoutePoint(
          id: null,
          workoutId: workoutId,
          latitude: point.latitude,
          longitude: point.longitude,
          timestamp: point.timestamp,
        ),
    ];
  }

  Future<int> save(WorkoutRepository repository) async {
    return repository.saveWorkoutWithRoutePoints(
      toWorkout(),
      routePointsForWorkout,
    );
  }
}
