import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitquest/src/data/goals/drift_weekly_goal_repository.dart';
import 'package:fitquest/src/data/local/app_database.dart';
import 'package:fitquest/src/goals/domain/weekly_goal.dart';

void main() {
  late AppDatabase database;
  late DriftWeeklyGoalRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftWeeklyGoalRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('missing weekly goal returns null', () async {
    final goal = await repository.getWeeklyGoalForWeek(DateTime(2026, 1, 5));

    expect(goal, isNull);
  });

  test('setWeeklyGoal stores and reads a weekly goal', () async {
    final weekStart = DateTime(2026, 1, 5);

    await repository.setWeeklyGoal(
      WeeklyGoal(
        id: null,
        weekStartDate: weekStart,
        targetDistanceMeters: 10000,
      ),
    );

    final goal = await repository.getWeeklyGoalForWeek(weekStart);

    expect(goal, isNotNull);
    expect(goal!.id, isPositive);
    expect(goal.weekStartDate, weekStart);
    expect(goal.targetDistanceMeters, 10000);
  });

  test('setWeeklyGoal updates an existing week goal', () async {
    final weekStart = DateTime(2026, 1, 5);

    await repository.setWeeklyGoal(
      WeeklyGoal(
        id: null,
        weekStartDate: weekStart,
        targetDistanceMeters: 8000,
      ),
    );
    await repository.setWeeklyGoal(
      WeeklyGoal(
        id: null,
        weekStartDate: weekStart,
        targetDistanceMeters: 12000,
      ),
    );

    final goal = await repository.getWeeklyGoalForWeek(weekStart);

    expect(goal, isNotNull);
    expect(goal!.targetDistanceMeters, 12000);
  });
}
