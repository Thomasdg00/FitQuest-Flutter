import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/workout/workout_repository_provider.dart';
import '../../domain/workout/route_point.dart';
import '../../domain/workout/workout.dart';

final workoutHistoryProvider = FutureProvider<List<Workout>>((ref) {
  return ref.watch(workoutRepositoryProvider).getWorkouts();
});

final workoutRoutePointsProvider = FutureProvider.family<List<RoutePoint>, int>(
  (ref, workoutId) {
    return ref
        .watch(workoutRepositoryProvider)
        .getRoutePointsForWorkout(workoutId);
  },
);
