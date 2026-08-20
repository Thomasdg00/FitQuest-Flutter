import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../goals/application/weekly_goal_providers.dart';
import '../../goals/domain/weekly_goal_progress.dart';
import '../../history/application/history_providers.dart';

final currentDateProvider = Provider<DateTime>((ref) => DateTime.now());

final weeklyGoalProgressProvider = FutureProvider<WeeklyGoalProgress>((
  ref,
) async {
  final today = ref.watch(currentDateProvider);
  final weekStart = weekStartFor(today);
  final goalRepository = ref.watch(weeklyGoalRepositoryProvider);
  final goal = await goalRepository.getWeeklyGoalForWeek(weekStart);
  final workouts = await ref.watch(workoutHistoryProvider.future);

  return calculateWeeklyGoalProgress(
    today: today,
    goal: goal,
    workouts: workouts,
  );
});
