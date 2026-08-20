import 'package:flutter_test/flutter_test.dart';

import 'package:fitquest/src/domain/workout/workout.dart';
import 'package:fitquest/src/goals/domain/weekly_goal.dart';
import 'package:fitquest/src/goals/domain/weekly_goal_progress.dart';

void main() {
  test('weekStartFor returns Monday at local midnight', () {
    expect(weekStartFor(DateTime(2026, 1, 7, 15, 30)), DateTime(2026, 1, 5));
    expect(weekStartFor(DateTime(2026, 1, 11, 23, 59)), DateTime(2026, 1, 5));
    expect(weekStartFor(DateTime(2026, 1, 12, 8)), DateTime(2026, 1, 12));
  });

  test('progress with no goal has empty target and zero ratio', () {
    final progress = calculateWeeklyGoalProgress(
      today: DateTime(2026, 1, 7, 12),
      goal: null,
      workouts: [
        _workout(startedAt: DateTime(2026, 1, 7, 9), distanceMeters: 3000),
      ],
    );

    expect(progress.hasGoal, isFalse);
    expect(progress.weekStartDate, DateTime(2026, 1, 5));
    expect(progress.targetDistanceMeters, 0);
    expect(progress.completedDistanceMeters, 3000);
    expect(progress.progressRatio, 0);
    expect(progress.remainingDistanceMeters, 0);
    expect(progress.isCompleted, isFalse);
  });

  test('progress with no workouts keeps full remaining distance', () {
    final progress = calculateWeeklyGoalProgress(
      today: DateTime(2026, 1, 7, 12),
      goal: _goal(targetDistanceMeters: 10000),
      workouts: const [],
    );

    expect(progress.hasGoal, isTrue);
    expect(progress.targetDistanceMeters, 10000);
    expect(progress.completedDistanceMeters, 0);
    expect(progress.progressRatio, 0);
    expect(progress.remainingDistanceMeters, 10000);
    expect(progress.isCompleted, isFalse);
  });

  test('progress reports partial completion', () {
    final progress = calculateWeeklyGoalProgress(
      today: DateTime(2026, 1, 7, 12),
      goal: _goal(targetDistanceMeters: 10000),
      workouts: [
        _workout(startedAt: DateTime(2026, 1, 5, 9), distanceMeters: 2500),
        _workout(startedAt: DateTime(2026, 1, 7, 18), distanceMeters: 1500),
      ],
    );

    expect(progress.completedDistanceMeters, 4000);
    expect(progress.progressRatio, 0.4);
    expect(progress.remainingDistanceMeters, 6000);
    expect(progress.isCompleted, isFalse);
  });

  test('progress ratio is clamped at one hundred percent', () {
    final progress = calculateWeeklyGoalProgress(
      today: DateTime(2026, 1, 7, 12),
      goal: _goal(targetDistanceMeters: 10000),
      workouts: [
        _workout(startedAt: DateTime(2026, 1, 7, 9), distanceMeters: 12000),
      ],
    );

    expect(progress.completedDistanceMeters, 12000);
    expect(progress.progressRatio, 1);
    expect(progress.remainingDistanceMeters, 0);
    expect(progress.isCompleted, isTrue);
  });

  test('workouts outside current week are ignored', () {
    final progress = calculateWeeklyGoalProgress(
      today: DateTime(2026, 1, 7, 12),
      goal: _goal(targetDistanceMeters: 10000),
      workouts: [
        _workout(startedAt: DateTime(2026, 1, 4, 23, 59), distanceMeters: 3000),
        _workout(startedAt: DateTime(2026, 1, 5, 0), distanceMeters: 2000),
        _workout(startedAt: DateTime(2026, 1, 12, 0), distanceMeters: 4000),
      ],
    );

    expect(progress.completedDistanceMeters, 2000);
    expect(progress.progressRatio, 0.2);
    expect(progress.remainingDistanceMeters, 8000);
  });
}

WeeklyGoal _goal({required double targetDistanceMeters}) {
  return WeeklyGoal(
    id: 1,
    weekStartDate: DateTime(2026, 1, 5),
    targetDistanceMeters: targetDistanceMeters,
  );
}

Workout _workout({
  required DateTime startedAt,
  required double distanceMeters,
}) {
  return Workout(
    id: null,
    startedAt: startedAt,
    duration: const Duration(minutes: 30),
    distanceMeters: distanceMeters,
  );
}
