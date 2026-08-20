import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../goals/application/weekly_goal_providers.dart';
import '../../goals/domain/weekly_goal.dart';
import '../../goals/domain/weekly_goal_repository.dart';

final homeGoalControllerProvider = Provider<HomeGoalController>((ref) {
  return HomeGoalController(ref.watch(weeklyGoalRepositoryProvider));
});

class HomeGoalController {
  const HomeGoalController(this._repository);

  final WeeklyGoalRepository _repository;

  Future<void> setGoalForWeek({
    required DateTime weekStartDate,
    required double targetKm,
  }) async {
    await _repository.setWeeklyGoal(
      WeeklyGoal(
        id: null,
        weekStartDate: weekStartDate,
        targetDistanceMeters: targetKm * 1000,
      ),
    );
  }
}
