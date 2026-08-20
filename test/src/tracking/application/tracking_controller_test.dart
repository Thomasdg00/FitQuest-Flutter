import 'package:flutter_test/flutter_test.dart';

import 'package:fitquest/src/domain/workout/route_point.dart';
import 'package:fitquest/src/domain/workout/workout.dart';
import 'package:fitquest/src/domain/workout/workout_repository.dart';
import 'package:fitquest/src/tracking/application/tracking_controller.dart';
import 'package:fitquest/src/tracking/application/tracking_state.dart';

void main() {
  test('initial state is stopped', () {
    final controller = TrackingController();

    expect(controller.state.status, TrackingStatus.stopped);
    expect(controller.state.startedAt, isNull);
    expect(controller.state.elapsedDuration, Duration.zero);
    expect(controller.state.distanceMeters, 0);
    expect(controller.state.routePoints, isEmpty);
  });

  test('start moves to running', () {
    final controller = TrackingController();
    final startedAt = DateTime.utc(2026, 1, 1, 8);

    controller.start(at: startedAt);

    expect(controller.state.status, TrackingStatus.running);
    expect(controller.state.startedAt, startedAt);
    expect(
      controller.elapsedAt(startedAt.add(const Duration(minutes: 3))),
      const Duration(minutes: 3),
    );
  });

  test('pause moves to paused', () {
    final controller = TrackingController();
    final startedAt = DateTime.utc(2026, 1, 1, 8);

    controller.start(at: startedAt);
    controller.pause(at: startedAt.add(const Duration(minutes: 5)));

    expect(controller.state.status, TrackingStatus.paused);
    expect(controller.state.elapsedDuration, const Duration(minutes: 5));
  });

  test('resume moves back to running', () {
    final controller = TrackingController();
    final startedAt = DateTime.utc(2026, 1, 1, 8);

    controller.start(at: startedAt);
    controller.pause(at: startedAt.add(const Duration(minutes: 5)));
    controller.resume(at: startedAt.add(const Duration(minutes: 9)));

    expect(controller.state.status, TrackingStatus.running);
    expect(
      controller.elapsedAt(startedAt.add(const Duration(minutes: 11))),
      const Duration(minutes: 7),
    );
  });

  test('elapsed duration excludes paused time', () {
    final controller = TrackingController();
    final startedAt = DateTime.utc(2026, 1, 1, 8);

    controller.start(at: startedAt);
    controller.pause(at: startedAt.add(const Duration(minutes: 5)));
    controller.resume(at: startedAt.add(const Duration(minutes: 15)));
    final elapsed = controller.elapsedAt(
      startedAt.add(const Duration(minutes: 20)),
    );

    expect(elapsed, const Duration(minutes: 10));
  });

  test('points added while paused are ignored', () {
    final controller = TrackingController();
    final startedAt = DateTime.utc(2026, 1, 1, 8);

    controller.start(at: startedAt);
    final acceptedBeforePause = controller.recordPoint(
      latitude: 43.6158,
      longitude: 13.5189,
      at: startedAt.add(const Duration(seconds: 5)),
    );
    controller.pause(at: startedAt.add(const Duration(minutes: 1)));
    final acceptedWhilePaused = controller.recordPoint(
      latitude: 43.6160,
      longitude: 13.5191,
      at: startedAt.add(const Duration(minutes: 2)),
    );

    expect(acceptedBeforePause, isTrue);
    expect(acceptedWhilePaused, isFalse);
    expect(controller.state.routePoints, hasLength(1));
  });

  test('distance increases when valid points are added', () {
    final controller = TrackingController();
    final startedAt = DateTime.utc(2026, 1, 1, 8);

    controller.start(at: startedAt);
    controller.recordPoint(
      latitude: 43.6158,
      longitude: 13.5189,
      at: startedAt.add(const Duration(seconds: 5)),
    );
    controller.recordPoint(
      latitude: 43.6160,
      longitude: 13.5191,
      at: startedAt.add(const Duration(seconds: 15)),
    );

    expect(controller.state.routePoints, hasLength(2));
    expect(controller.state.distanceMeters, closeTo(27.4, 1));
  });

  test('invalid and duplicate points are ignored', () {
    final controller = TrackingController();
    final startedAt = DateTime.utc(2026, 1, 1, 8);

    controller.start(at: startedAt);
    final invalidAccepted = controller.recordPoint(
      latitude: 95,
      longitude: 13.5189,
      at: startedAt.add(const Duration(seconds: 5)),
    );
    final firstAccepted = controller.recordPoint(
      latitude: 43.6158,
      longitude: 13.5189,
      at: startedAt.add(const Duration(seconds: 10)),
    );
    final duplicateAccepted = controller.recordPoint(
      latitude: 43.6158,
      longitude: 13.5189,
      at: startedAt.add(const Duration(seconds: 20)),
    );

    expect(invalidAccepted, isFalse);
    expect(firstAccepted, isTrue);
    expect(duplicateAccepted, isFalse);
    expect(controller.state.routePoints, hasLength(1));
    expect(controller.state.distanceMeters, 0);
  });

  test('stop finalizes a workout session', () {
    final controller = TrackingController();
    final startedAt = DateTime.utc(2026, 1, 1, 8);
    final stoppedAt = startedAt.add(const Duration(minutes: 12));

    controller.start(at: startedAt);
    controller.recordPoint(
      latitude: 43.6158,
      longitude: 13.5189,
      at: startedAt.add(const Duration(seconds: 5)),
    );
    controller.recordPoint(
      latitude: 43.6160,
      longitude: 13.5191,
      at: startedAt.add(const Duration(seconds: 15)),
    );
    final session = controller.stop(at: stoppedAt);

    expect(controller.state.status, TrackingStatus.stopped);
    expect(session, isNotNull);
    expect(session!.startedAt, startedAt);
    expect(session.endedAt, stoppedAt);
    expect(session.duration, const Duration(minutes: 12));
    expect(session.routePoints, hasLength(2));
    expect(session.distanceMeters, closeTo(27.4, 1));
    expect(controller.lastFinalizedSession, session);
  });

  test('stop from paused finalizes without counting paused time', () {
    final controller = TrackingController();
    final startedAt = DateTime.utc(2026, 1, 1, 8);

    controller.start(at: startedAt);
    controller.pause(at: startedAt.add(const Duration(minutes: 5)));
    final session = controller.stop(
      at: startedAt.add(const Duration(minutes: 12)),
    );

    expect(session, isNotNull);
    expect(session!.duration, const Duration(minutes: 5));
    expect(controller.state.status, TrackingStatus.stopped);
  });

  test('duplicate start does not reset an active session', () {
    final controller = TrackingController();
    final startedAt = DateTime.utc(2026, 1, 1, 8);

    controller.start(at: startedAt);
    controller.recordPoint(
      latitude: 43.6158,
      longitude: 13.5189,
      at: startedAt.add(const Duration(seconds: 5)),
    );
    controller.start(at: startedAt.add(const Duration(minutes: 10)));

    expect(controller.state.status, TrackingStatus.running);
    expect(controller.state.startedAt, startedAt);
    expect(controller.state.routePoints, hasLength(1));
    expect(
      controller.elapsedAt(startedAt.add(const Duration(minutes: 11))),
      const Duration(minutes: 11),
    );
  });

  test('stopping without points does not crash', () {
    final controller = TrackingController();
    final startedAt = DateTime.utc(2026, 1, 1, 8);

    controller.start(at: startedAt);
    final session = controller.stop(
      at: startedAt.add(const Duration(minutes: 3)),
    );

    expect(session, isNotNull);
    expect(session!.routePoints, isEmpty);
    expect(session.distanceMeters, 0);
  });

  test('stop from stopped is safe', () {
    final controller = TrackingController();

    final session = controller.stop(at: DateTime.utc(2026, 1, 1, 8));

    expect(session, isNull);
    expect(controller.state.status, TrackingStatus.stopped);
  });

  test(
    'finalized session converts and saves through workout repository',
    () async {
      final controller = TrackingController();
      final repository = _FakeWorkoutRepository();
      final startedAt = DateTime.utc(2026, 1, 1, 8);

      controller.start(at: startedAt);
      controller.recordPoint(
        latitude: 43.6158,
        longitude: 13.5189,
        at: startedAt.add(const Duration(seconds: 5)),
      );
      controller.recordPoint(
        latitude: 43.6160,
        longitude: 13.5191,
        at: startedAt.add(const Duration(seconds: 15)),
      );
      final session = controller.stop(
        at: startedAt.add(const Duration(minutes: 4)),
      );

      final workoutId = await session!.save(repository);

      expect(workoutId, 42);
      expect(repository.saveWorkoutWithRoutePointsCount, 1);
      expect(repository.workouts, hasLength(1));
      expect(repository.workouts.single.startedAt, startedAt);
      expect(repository.workouts.single.duration, const Duration(minutes: 4));
      expect(repository.routePoints, hasLength(2));
      expect(repository.routePoints.first.workoutId, 42);
      expect(repository.routePoints.first.latitude, 43.6158);
      expect(repository.routePoints.last.longitude, 13.5191);
    },
  );
}

class _FakeWorkoutRepository implements WorkoutRepository {
  final workouts = <Workout>[];
  final routePoints = <RoutePoint>[];
  int saveWorkoutWithRoutePointsCount = 0;

  @override
  Future<List<RoutePoint>> getRoutePointsForWorkout(int workoutId) async {
    return routePoints
        .where((point) => point.workoutId == workoutId)
        .toList(growable: false);
  }

  @override
  Future<List<Workout>> getWorkouts() async {
    return List.unmodifiable(workouts);
  }

  @override
  Future<void> insertRoutePoints(List<RoutePoint> routePoints) {
    throw StateError('FinalizedTrackingSession.save must use atomic save.');
  }

  @override
  Future<int> insertWorkout(Workout workout) {
    throw StateError('FinalizedTrackingSession.save must use atomic save.');
  }

  @override
  Future<int> saveWorkoutWithRoutePoints(
    Workout workout,
    List<RoutePoint> Function(int workoutId) routePointsForWorkout,
  ) async {
    saveWorkoutWithRoutePointsCount += 1;
    workouts.add(workout);
    routePoints.addAll(routePointsForWorkout(42));
    return 42;
  }

  @override
  Future<void> deleteWorkout(int workoutId) {
    throw UnimplementedError('Tests do not delete workouts.');
  }
}
