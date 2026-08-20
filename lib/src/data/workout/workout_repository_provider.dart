import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/workout/workout_repository.dart';
import '../local/database_provider.dart';
import 'drift_workout_repository.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return DriftWorkoutRepository(ref.watch(appDatabaseProvider));
});
