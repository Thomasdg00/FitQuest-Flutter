import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class WorkoutRecords extends Table {
  @override
  String get tableName => 'workouts';

  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get durationSeconds => integer()();
  RealColumn get distanceMeters => real()();
}

class RoutePointRecords extends Table {
  @override
  String get tableName => 'route_points';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutId => integer().customConstraint(
    'NOT NULL REFERENCES workouts(id) ON DELETE CASCADE',
  )();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get timestamp => dateTime()();
}

class WeeklyGoalRecords extends Table {
  @override
  String get tableName => 'weekly_goals';

  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get weekStartDate => dateTime()();
  RealColumn get targetDistanceMeters => real()();
}

@DriftDatabase(tables: [WorkoutRecords, RoutePointRecords, WeeklyGoalRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(weeklyGoalRecords);
        }
        if (from < 3) {
          await customStatement('''
            DELETE FROM route_points
            WHERE NOT EXISTS (
              SELECT 1 FROM workouts
              WHERE workouts.id = route_points.workout_id
            )
          ''');
          // ignore: experimental_member_use
          await migrator.alterTable(TableMigration(routePointRecords));
        }
      },
      beforeOpen: (_) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'fitquest');
}
