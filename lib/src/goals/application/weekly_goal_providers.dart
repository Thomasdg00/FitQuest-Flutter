import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/goals/drift_weekly_goal_repository.dart';
import '../../data/local/database_provider.dart';
import '../domain/weekly_goal_repository.dart';

final weeklyGoalRepositoryProvider = Provider<WeeklyGoalRepository>((ref) {
  return DriftWeeklyGoalRepository(ref.watch(appDatabaseProvider));
});
