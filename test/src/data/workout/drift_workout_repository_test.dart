import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitquest/src/data/local/app_database.dart';
import 'package:fitquest/src/data/workout/drift_workout_repository.dart';
import 'package:fitquest/src/domain/workout/route_point.dart';
import 'package:fitquest/src/domain/workout/workout.dart';

void main() {
  late AppDatabase database;
  late DriftWorkoutRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftWorkoutRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('empty history returns empty list', () async {
    final workouts = await repository.getWorkouts();

    expect(workouts, isEmpty);
  });

  test('insertWorkout stores a workout in history', () async {
    final startedAt = DateTime.utc(2026, 1, 2, 8, 30);

    final id = await repository.insertWorkout(
      Workout(
        id: null,
        startedAt: startedAt,
        duration: const Duration(minutes: 42),
        distanceMeters: 6400,
      ),
    );

    final workouts = await repository.getWorkouts();

    expect(id, isPositive);
    expect(workouts, hasLength(1));
    expect(workouts.single.id, id);
    expect(workouts.single.startedAt.isUtc, isTrue);
    expect(workouts.single.startedAt, startedAt);
    expect(workouts.single.duration, const Duration(minutes: 42));
    expect(workouts.single.distanceMeters, 6400);
  });

  test('getWorkouts returns workout history newest first', () async {
    await repository.insertWorkout(
      Workout(
        id: null,
        startedAt: DateTime.utc(2026, 1, 1, 9),
        duration: const Duration(minutes: 30),
        distanceMeters: 5000,
      ),
    );
    await repository.insertWorkout(
      Workout(
        id: null,
        startedAt: DateTime.utc(2026, 1, 3, 9),
        duration: const Duration(minutes: 20),
        distanceMeters: 3000,
      ),
    );

    final workouts = await repository.getWorkouts();

    expect(workouts, hasLength(2));
    expect(workouts.first.startedAt.isUtc, isTrue);
    expect(workouts.last.startedAt.isUtc, isTrue);
    expect(workouts.first.startedAt, DateTime.utc(2026, 1, 3, 9));
    expect(workouts.last.startedAt, DateTime.utc(2026, 1, 1, 9));
  });

  test('empty route points for a workout returns empty list', () async {
    final workoutId = await repository.insertWorkout(
      Workout(
        id: null,
        startedAt: DateTime.utc(2026, 1, 4, 10),
        duration: const Duration(minutes: 10),
        distanceMeters: 1000,
      ),
    );

    final points = await repository.getRoutePointsForWorkout(workoutId);

    expect(points, isEmpty);
  });

  test('insertRoutePoints stores points linked to a workout', () async {
    final workoutId = await repository.insertWorkout(
      Workout(
        id: null,
        startedAt: DateTime.utc(2026, 1, 5, 10),
        duration: const Duration(minutes: 12),
        distanceMeters: 1500,
      ),
    );
    final firstTimestamp = DateTime.utc(2026, 1, 5, 10, 1);
    final secondTimestamp = DateTime.utc(2026, 1, 5, 10, 2);

    await repository.insertRoutePoints([
      RoutePoint(
        id: null,
        workoutId: workoutId,
        latitude: 43.6158,
        longitude: 13.5189,
        timestamp: firstTimestamp,
      ),
      RoutePoint(
        id: null,
        workoutId: workoutId,
        latitude: 43.6160,
        longitude: 13.5191,
        timestamp: secondTimestamp,
      ),
    ]);

    final points = await repository.getRoutePointsForWorkout(workoutId);

    expect(points, hasLength(2));
    expect(points.first.workoutId, workoutId);
    expect(points.first.latitude, 43.6158);
    expect(points.first.longitude, 13.5189);
    expect(points.first.timestamp.isUtc, isTrue);
    expect(points.first.timestamp, firstTimestamp);
    expect(points.last.latitude, 43.6160);
    expect(points.last.longitude, 13.5191);
    expect(points.last.timestamp.isUtc, isTrue);
    expect(points.last.timestamp, secondTimestamp);
  });

  test('saveWorkoutWithRoutePoints stores workout and linked points', () async {
    final startedAt = DateTime.utc(2026, 1, 8, 10);
    final firstTimestamp = DateTime.utc(2026, 1, 8, 10, 1);
    final secondTimestamp = DateTime.utc(2026, 1, 8, 10, 2);

    final workoutId = await repository.saveWorkoutWithRoutePoints(
      Workout(
        id: null,
        startedAt: startedAt,
        duration: const Duration(minutes: 18),
        distanceMeters: 2200,
      ),
      (workoutId) => [
        RoutePoint(
          id: null,
          workoutId: workoutId,
          latitude: 43.6158,
          longitude: 13.5189,
          timestamp: firstTimestamp,
        ),
        RoutePoint(
          id: null,
          workoutId: workoutId,
          latitude: 43.6160,
          longitude: 13.5191,
          timestamp: secondTimestamp,
        ),
      ],
    );

    final workouts = await repository.getWorkouts();
    final points = await repository.getRoutePointsForWorkout(workoutId);

    expect(workoutId, isPositive);
    expect(workouts, hasLength(1));
    expect(workouts.single.id, workoutId);
    expect(workouts.single.startedAt, startedAt);
    expect(points, hasLength(2));
    expect(points.every((point) => point.workoutId == workoutId), isTrue);
    expect(points.first.timestamp, firstTimestamp);
    expect(points.last.timestamp, secondTimestamp);
  });

  test(
    'saveWorkoutWithRoutePoints rolls back workout when route points fail',
    () async {
      final failingRepository = _FailingRoutePointInsertRepository(database);

      await expectLater(
        failingRepository.saveWorkoutWithRoutePoints(
          Workout(
            id: null,
            startedAt: DateTime.utc(2026, 1, 9, 10),
            duration: const Duration(minutes: 18),
            distanceMeters: 2200,
          ),
          (workoutId) => [
            RoutePoint(
              id: null,
              workoutId: workoutId,
              latitude: 43.6158,
              longitude: 13.5189,
              timestamp: DateTime.utc(2026, 1, 9, 10, 1),
            ),
          ],
        ),
        throwsA(isA<StateError>()),
      );

      final workouts = await repository.getWorkouts();

      expect(workouts, isEmpty);
    },
  );

  test(
    'getRoutePointsForWorkout returns only requested workout points',
    () async {
      final firstWorkoutId = await repository.insertWorkout(
        Workout(
          id: null,
          startedAt: DateTime.utc(2026, 1, 6, 10),
          duration: const Duration(minutes: 15),
          distanceMeters: 1800,
        ),
      );
      final secondWorkoutId = await repository.insertWorkout(
        Workout(
          id: null,
          startedAt: DateTime.utc(2026, 1, 7, 10),
          duration: const Duration(minutes: 15),
          distanceMeters: 1800,
        ),
      );

      await repository.insertRoutePoints([
        RoutePoint(
          id: null,
          workoutId: firstWorkoutId,
          latitude: 43.0,
          longitude: 13.0,
          timestamp: DateTime.utc(2026, 1, 6, 10, 1),
        ),
        RoutePoint(
          id: null,
          workoutId: secondWorkoutId,
          latitude: 44.0,
          longitude: 14.0,
          timestamp: DateTime.utc(2026, 1, 7, 10, 1),
        ),
      ]);

      final points = await repository.getRoutePointsForWorkout(secondWorkoutId);

      expect(points, hasLength(1));
      expect(points.single.workoutId, secondWorkoutId);
      expect(points.single.latitude, 44.0);
    },
  );
  test('deleteWorkout removes the workout', () async {
    final workoutId = await repository.insertWorkout(
      Workout(
        id: null,
        startedAt: DateTime.utc(2026, 1, 10, 10),
        duration: const Duration(minutes: 20),
        distanceMeters: 2400,
      ),
    );

    await repository.deleteWorkout(workoutId);

    final workouts = await repository.getWorkouts();

    expect(workouts, isEmpty);
  });

  test('deleteWorkout removes associated route points', () async {
    final workoutId = await repository.insertWorkout(
      Workout(
        id: null,
        startedAt: DateTime.utc(2026, 1, 11, 10),
        duration: const Duration(minutes: 20),
        distanceMeters: 2400,
      ),
    );
    await repository.insertRoutePoints([
      RoutePoint(
        id: null,
        workoutId: workoutId,
        latitude: 43.6158,
        longitude: 13.5189,
        timestamp: DateTime.utc(2026, 1, 11, 10, 1),
      ),
    ]);

    await repository.deleteWorkout(workoutId);

    final points = await repository.getRoutePointsForWorkout(workoutId);

    expect(points, isEmpty);
  });

  test(
    'deleteWorkout does not remove another workout or route points',
    () async {
      final firstWorkoutId = await repository.insertWorkout(
        Workout(
          id: null,
          startedAt: DateTime.utc(2026, 1, 12, 10),
          duration: const Duration(minutes: 20),
          distanceMeters: 2400,
        ),
      );
      final secondWorkoutId = await repository.insertWorkout(
        Workout(
          id: null,
          startedAt: DateTime.utc(2026, 1, 13, 10),
          duration: const Duration(minutes: 30),
          distanceMeters: 3200,
        ),
      );
      await repository.insertRoutePoints([
        RoutePoint(
          id: null,
          workoutId: firstWorkoutId,
          latitude: 43.0,
          longitude: 13.0,
          timestamp: DateTime.utc(2026, 1, 12, 10, 1),
        ),
        RoutePoint(
          id: null,
          workoutId: secondWorkoutId,
          latitude: 44.0,
          longitude: 14.0,
          timestamp: DateTime.utc(2026, 1, 13, 10, 1),
        ),
      ]);

      await repository.deleteWorkout(firstWorkoutId);

      final workouts = await repository.getWorkouts();
      final firstPoints = await repository.getRoutePointsForWorkout(
        firstWorkoutId,
      );
      final secondPoints = await repository.getRoutePointsForWorkout(
        secondWorkoutId,
      );

      expect(workouts, hasLength(1));
      expect(workouts.single.id, secondWorkoutId);
      expect(firstPoints, isEmpty);
      expect(secondPoints, hasLength(1));
      expect(secondPoints.single.workoutId, secondWorkoutId);
    },
  );

  test('in-memory database enables foreign keys', () async {
    final row = await database.customSelect('PRAGMA foreign_keys').getSingle();

    expect(row.data['foreign_keys'], 1);
  });

  test('direct workout delete cascades route points', () async {
    final workoutId = await repository.insertWorkout(
      Workout(
        id: null,
        startedAt: DateTime.utc(2026, 1, 14, 10),
        duration: const Duration(minutes: 20),
        distanceMeters: 2400,
      ),
    );
    await repository.insertRoutePoints([
      RoutePoint(
        id: null,
        workoutId: workoutId,
        latitude: 43.6158,
        longitude: 13.5189,
        timestamp: DateTime.utc(2026, 1, 14, 10, 1),
      ),
    ]);

    await (database.delete(
      database.workoutRecords,
    )..where((table) => table.id.equals(workoutId))).go();

    final points = await repository.getRoutePointsForWorkout(workoutId);

    expect(points, isEmpty);
  });

  test('v3 migration keeps valid route points and removes orphans', () async {
    await database.close();

    database = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (rawDatabase) {
          rawDatabase
            ..execute('''
                CREATE TABLE workouts (
                  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                  started_at INTEGER NOT NULL,
                  duration_seconds INTEGER NOT NULL,
                  distance_meters REAL NOT NULL
                );
              ''')
            ..execute('''
                CREATE TABLE route_points (
                  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                  workout_id INTEGER NOT NULL REFERENCES workouts(id),
                  latitude REAL NOT NULL,
                  longitude REAL NOT NULL,
                  timestamp INTEGER NOT NULL
                );
              ''')
            ..execute('''
                CREATE TABLE weekly_goals (
                  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                  week_start_date INTEGER NOT NULL,
                  target_distance_meters REAL NOT NULL
                );
              ''')
            ..execute('''
                INSERT INTO workouts (
                  id,
                  started_at,
                  duration_seconds,
                  distance_meters
                )
                VALUES (1, 1768125600000, 1200, 2400.0);
              ''')
            ..execute('''
                INSERT INTO route_points (
                  id,
                  workout_id,
                  latitude,
                  longitude,
                  timestamp
                )
                VALUES (1, 1, 43.6158, 13.5189, 1768125660000);
              ''')
            ..execute('''
                INSERT INTO route_points (
                  id,
                  workout_id,
                  latitude,
                  longitude,
                  timestamp
                )
                VALUES (2, 999, 44.0, 14.0, 1768125720000);
              ''')
            ..execute('PRAGMA user_version = 2;');
        },
      ),
    );
    repository = DriftWorkoutRepository(database);

    final rows = await database
        .customSelect('SELECT id, workout_id FROM route_points ORDER BY id')
        .get();

    expect(rows, hasLength(1));
    expect(rows.single.data['id'], 1);
    expect(rows.single.data['workout_id'], 1);
  });
}

class _FailingRoutePointInsertRepository extends DriftWorkoutRepository {
  _FailingRoutePointInsertRepository(super.database);

  @override
  Future<void> insertRoutePoints(List<RoutePoint> routePoints) {
    throw StateError('route point insert failed');
  }
}
