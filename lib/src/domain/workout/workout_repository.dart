import 'route_point.dart';
import 'workout.dart';

abstract class WorkoutRepository {
  Future<int> insertWorkout(Workout workout);

  Future<void> insertRoutePoints(List<RoutePoint> routePoints);

  Future<int> saveWorkoutWithRoutePoints(
    Workout workout,
    List<RoutePoint> Function(int workoutId) routePointsForWorkout,
  );

  Future<List<Workout>> getWorkouts();

  Future<List<RoutePoint>> getRoutePointsForWorkout(int workoutId);

  Future<void> deleteWorkout(int workoutId);
}
