import 'package:drift/drift.dart';

import '../../domain/workout/route_point.dart';
import '../../domain/workout/workout.dart';
import '../../domain/workout/workout_repository.dart';
import '../local/app_database.dart';

class DriftWorkoutRepository implements WorkoutRepository {
  DriftWorkoutRepository(this._database);

  final AppDatabase _database;

  @override
  Future<int> insertWorkout(Workout workout) {
    return _database
        .into(_database.workoutRecords)
        .insert(
          WorkoutRecordsCompanion.insert(
            startedAt: workout.startedAt.toUtc(),
            durationSeconds: workout.duration.inSeconds,
            distanceMeters: workout.distanceMeters,
          ),
        );
  }

  @override
  Future<void> insertRoutePoints(List<RoutePoint> routePoints) async {
    if (routePoints.isEmpty) {
      return;
    }

    await _database.batch((batch) {
      batch.insertAll(
        _database.routePointRecords,
        routePoints.map(_toRoutePointCompanion).toList(growable: false),
      );
    });
  }

  @override
  Future<int> saveWorkoutWithRoutePoints(
    Workout workout,
    List<RoutePoint> Function(int workoutId) routePointsForWorkout,
  ) {
    return _database.transaction(() async {
      final workoutId = await insertWorkout(workout);
      await insertRoutePoints(routePointsForWorkout(workoutId));
      return workoutId;
    });
  }

  @override
  Future<List<Workout>> getWorkouts() async {
    final query = _database.select(_database.workoutRecords)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.startedAt, mode: OrderingMode.desc),
      ]);

    final rows = await query.get();
    return rows.map(_toWorkout).toList(growable: false);
  }

  @override
  Future<List<RoutePoint>> getRoutePointsForWorkout(int workoutId) async {
    final query = _database.select(_database.routePointRecords)
      ..where((table) => table.workoutId.equals(workoutId))
      ..orderBy([(table) => OrderingTerm(expression: table.timestamp)]);

    final rows = await query.get();
    return rows.map(_toRoutePoint).toList(growable: false);
  }

  @override
  Future<void> deleteWorkout(int workoutId) {
    return _database.transaction(() async {
      await (_database.delete(
        _database.routePointRecords,
      )..where((table) => table.workoutId.equals(workoutId))).go();
      await (_database.delete(
        _database.workoutRecords,
      )..where((table) => table.id.equals(workoutId))).go();
    });
  }

  static Workout _toWorkout(WorkoutRecord row) {
    return Workout(
      id: row.id,
      startedAt: row.startedAt.toUtc(),
      duration: Duration(seconds: row.durationSeconds),
      distanceMeters: row.distanceMeters,
    );
  }

  static RoutePoint _toRoutePoint(RoutePointRecord row) {
    return RoutePoint(
      id: row.id,
      workoutId: row.workoutId,
      latitude: row.latitude,
      longitude: row.longitude,
      timestamp: row.timestamp.toUtc(),
    );
  }

  static RoutePointRecordsCompanion _toRoutePointCompanion(RoutePoint point) {
    return RoutePointRecordsCompanion.insert(
      workoutId: point.workoutId,
      latitude: point.latitude,
      longitude: point.longitude,
      timestamp: point.timestamp.toUtc(),
    );
  }
}
