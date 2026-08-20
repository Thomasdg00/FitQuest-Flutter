import '../../domain/workout/workout.dart';
import 'weekly_goal.dart';

class WeeklyGoalProgress {
  const WeeklyGoalProgress({
    required this.weekStartDate,
    required this.targetDistanceMeters,
    required this.completedDistanceMeters,
    required this.progressRatio,
    required this.remainingDistanceMeters,
    required this.isCompleted,
    required this.hasGoal,
  });

  final DateTime weekStartDate;
  final double targetDistanceMeters;
  final double completedDistanceMeters;
  final double progressRatio;
  final double remainingDistanceMeters;
  final bool isCompleted;
  final bool hasGoal;
}

DateTime weekStartFor(DateTime date) {
  final local = date.toLocal();
  final localDate = DateTime(local.year, local.month, local.day);
  return localDate.subtract(Duration(days: local.weekday - DateTime.monday));
}

WeeklyGoalProgress calculateWeeklyGoalProgress({
  required DateTime today,
  required WeeklyGoal? goal,
  required List<Workout> workouts,
}) {
  final weekStart = weekStartFor(today);
  final weekEnd = weekStart.add(const Duration(days: 7));
  final completedDistance = workouts
      .where((workout) => _isInWeek(workout.startedAt, weekStart, weekEnd))
      .fold<double>(0, (total, workout) => total + workout.distanceMeters);

  if (goal == null) {
    return WeeklyGoalProgress(
      weekStartDate: weekStart,
      targetDistanceMeters: 0,
      completedDistanceMeters: completedDistance,
      progressRatio: 0,
      remainingDistanceMeters: 0,
      isCompleted: false,
      hasGoal: false,
    );
  }

  final targetDistance = goal.targetDistanceMeters;
  final ratio = targetDistance <= 0 ? 0.0 : completedDistance / targetDistance;
  final clampedRatio = ratio.clamp(0.0, 1.0).toDouble();
  final remainingDistance = targetDistance - completedDistance;

  return WeeklyGoalProgress(
    weekStartDate: weekStart,
    targetDistanceMeters: targetDistance,
    completedDistanceMeters: completedDistance,
    progressRatio: clampedRatio,
    remainingDistanceMeters: remainingDistance > 0 ? remainingDistance : 0,
    isCompleted: targetDistance > 0 && completedDistance >= targetDistance,
    hasGoal: true,
  );
}

bool _isInWeek(DateTime startedAt, DateTime weekStart, DateTime weekEnd) {
  final local = startedAt.toLocal();
  return !local.isBefore(weekStart) && local.isBefore(weekEnd);
}
