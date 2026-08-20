import 'package:drift/drift.dart';

import '../local/app_database.dart';
import '../../goals/domain/weekly_goal.dart';
import '../../goals/domain/weekly_goal_repository.dart';

class DriftWeeklyGoalRepository implements WeeklyGoalRepository {
  DriftWeeklyGoalRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> setWeeklyGoal(WeeklyGoal goal) async {
    final weekStartDate = _dateOnly(goal.weekStartDate);
    final existing = await getWeeklyGoalForWeek(weekStartDate);

    if (existing == null) {
      await _database
          .into(_database.weeklyGoalRecords)
          .insert(
            WeeklyGoalRecordsCompanion.insert(
              weekStartDate: weekStartDate,
              targetDistanceMeters: goal.targetDistanceMeters,
            ),
          );
      return;
    }

    await (_database.update(
      _database.weeklyGoalRecords,
    )..where((table) => table.id.equals(existing.id!))).write(
      WeeklyGoalRecordsCompanion(
        weekStartDate: Value(weekStartDate),
        targetDistanceMeters: Value(goal.targetDistanceMeters),
      ),
    );
  }

  @override
  Future<WeeklyGoal?> getWeeklyGoalForWeek(DateTime weekStartDate) async {
    final query = _database.select(_database.weeklyGoalRecords)
      ..where((table) => table.weekStartDate.equals(_dateOnly(weekStartDate)))
      ..limit(1);

    final row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }

    return WeeklyGoal(
      id: row.id,
      weekStartDate: _dateOnly(row.weekStartDate),
      targetDistanceMeters: row.targetDistanceMeters,
    );
  }

  DateTime _dateOnly(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
