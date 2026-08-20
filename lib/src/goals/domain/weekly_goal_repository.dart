import 'weekly_goal.dart';

abstract class WeeklyGoalRepository {
  Future<void> setWeeklyGoal(WeeklyGoal goal);

  Future<WeeklyGoal?> getWeeklyGoalForWeek(DateTime weekStartDate);
}
