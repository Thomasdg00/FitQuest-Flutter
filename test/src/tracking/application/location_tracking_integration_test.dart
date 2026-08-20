import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitquest/src/data/workout/workout_repository_provider.dart';
import 'package:fitquest/src/domain/workout/route_point.dart';
import 'package:fitquest/src/domain/workout/workout.dart';
import 'package:fitquest/src/domain/workout/workout_repository.dart';
import 'package:fitquest/src/tracking/application/tracking_providers.dart';
import 'package:fitquest/src/tracking/application/tracking_save_result.dart';
import 'package:fitquest/src/tracking/domain/location_fix.dart';
import 'package:fitquest/src/tracking/domain/location_tracker.dart';

void main() {
  test(
    'start checks the fake location tracker and listens for GPS points',
    () async {
      final tracker = FakeLocationTracker();
      final container = _container(locationTracker: tracker);
      final notifier = container.read(trackingControllerProvider.notifier);

      await notifier.start();

      expect(tracker.checkAvailabilityCount, 1);
      expect(tracker.requestPermissionCount, 0);
      expect(tracker.listenCount, 1);

      tracker.addPosition(
        LocationFix(
          latitude: 43.6158,
          longitude: 13.5189,
          timestamp: DateTime.utc(2026, 1, 1, 8),
        ),
      );

      expect(
        container.read(trackingControllerProvider).routePoints,
        hasLength(1),
      );
    },
  );

  test(
    'start requests permission when foreground permission is not granted',
    () async {
      final tracker = FakeLocationTracker(
        initialAvailability: LocationTrackingAvailability.permissionDenied,
        requestedAvailability: LocationTrackingAvailability.available,
      );
      final container = _container(locationTracker: tracker);
      final notifier = container.read(trackingControllerProvider.notifier);

      final result = await notifier.start();

      expect(result.availability, LocationTrackingAvailability.available);
      expect(tracker.checkAvailabilityCount, 1);
      expect(tracker.requestPermissionCount, 1);
      expect(tracker.listenCount, 1);
    },
  );

  test('GPS points while running update point count and distance', () async {
    final tracker = FakeLocationTracker();
    final container = _container(locationTracker: tracker);
    final notifier = container.read(trackingControllerProvider.notifier);

    await notifier.start();
    tracker.addPosition(
      LocationFix(
        latitude: 43.6158,
        longitude: 13.5189,
        timestamp: DateTime.utc(2026, 1, 1, 8),
      ),
    );
    tracker.addPosition(
      LocationFix(
        latitude: 43.6160,
        longitude: 13.5191,
        timestamp: DateTime.utc(2026, 1, 1, 8, 0, 5),
      ),
    );

    final state = container.read(trackingControllerProvider);

    expect(state.routePoints, hasLength(2));
    expect(state.distanceMeters, closeTo(27.4, 1));
  });

  test('GPS points while paused are ignored', () async {
    final tracker = FakeLocationTracker();
    final container = _container(locationTracker: tracker);
    final notifier = container.read(trackingControllerProvider.notifier);

    await notifier.start();
    tracker.addPosition(
      LocationFix(
        latitude: 43.6158,
        longitude: 13.5189,
        timestamp: DateTime.utc(2026, 1, 1, 8),
      ),
    );

    notifier.pause();
    tracker.addPosition(
      LocationFix(
        latitude: 43.6160,
        longitude: 13.5191,
        timestamp: DateTime.utc(2026, 1, 1, 8, 0, 5),
      ),
    );

    notifier.resume();
    tracker.addPosition(
      LocationFix(
        latitude: 43.6162,
        longitude: 13.5194,
        timestamp: DateTime.utc(2026, 1, 1, 8, 0, 10),
      ),
    );

    final state = container.read(trackingControllerProvider);

    expect(state.routePoints, hasLength(2));
    expect(state.routePoints.last.latitude, 43.6162);
  });

  test('stop cancels location stream and persists saved session', () async {
    final tracker = FakeLocationTracker();
    final repository = FakeWorkoutRepository();
    final container = _container(
      locationTracker: tracker,
      repository: repository,
    );
    final notifier = container.read(trackingControllerProvider.notifier);

    await notifier.start();
    tracker.addPosition(
      LocationFix(
        latitude: 43.6158,
        longitude: 13.5189,
        timestamp: DateTime.utc(2026, 1, 1, 8),
      ),
    );
    tracker.addPosition(
      LocationFix(
        latitude: 43.6160,
        longitude: 13.5191,
        timestamp: DateTime.utc(2026, 1, 1, 8, 0, 5),
      ),
    );

    final result = await notifier.stopAndSave();

    expect(result.status, TrackingSaveStatus.saved);
    expect(tracker.cancelCount, 1);
    expect(repository.workouts, hasLength(1));
    expect(repository.routePoints, hasLength(2));
    expect(
      repository.routePoints.every((point) => point.timestamp.isUtc),
      isTrue,
    );
  });

  test('permission denied stores a safe location message', () async {
    final tracker = FakeLocationTracker(
      initialAvailability: LocationTrackingAvailability.permissionDenied,
      requestedAvailability: LocationTrackingAvailability.permissionDenied,
    );
    final container = _container(locationTracker: tracker);
    final notifier = container.read(trackingControllerProvider.notifier);

    final result = await notifier.start();

    expect(result.availability, LocationTrackingAvailability.permissionDenied);
    expect(tracker.listenCount, 0);
    expect(
      container.read(trackingLocationMessageProvider),
      'Permesso di posizione negato. Concedi il permesso per tracciare il percorso.',
    );
  });

  test('service disabled stores a safe location message', () async {
    final tracker = FakeLocationTracker(
      initialAvailability: LocationTrackingAvailability.serviceDisabled,
    );
    final container = _container(locationTracker: tracker);
    final notifier = container.read(trackingControllerProvider.notifier);

    final result = await notifier.start();

    expect(result.availability, LocationTrackingAvailability.serviceDisabled);
    expect(tracker.requestPermissionCount, 0);
    expect(tracker.listenCount, 0);
    expect(
      container.read(trackingLocationMessageProvider),
      'Servizio di posizione disattivato. Attiva il GPS per tracciare il percorso.',
    );
  });

  test('permission denied forever stores a safe location message', () async {
    final tracker = FakeLocationTracker(
      initialAvailability: LocationTrackingAvailability.permissionDeniedForever,
    );
    final container = _container(locationTracker: tracker);
    final notifier = container.read(trackingControllerProvider.notifier);

    final result = await notifier.start();

    expect(
      result.availability,
      LocationTrackingAvailability.permissionDeniedForever,
    );
    expect(tracker.requestPermissionCount, 0);
    expect(tracker.listenCount, 0);
    expect(
      container.read(trackingLocationMessageProvider),
      'Permesso di posizione negato in modo permanente. Attivalo dalle impostazioni Android per tracciare il percorso.',
    );
  });

  test('position stream errors store a safe location message', () async {
    final tracker = FakeLocationTracker();
    final container = _container(locationTracker: tracker);
    final notifier = container.read(trackingControllerProvider.notifier);

    await notifier.start();
    tracker.addError(StateError('GPS stream failed'));

    expect(
      container.read(trackingLocationMessageProvider),
      'Aggiornamenti posizione interrotti. Controlla il GPS e riprova.',
    );
  });
}

ProviderContainer _container({
  FakeLocationTracker? locationTracker,
  WorkoutRepository? repository,
}) {
  final tracker = locationTracker ?? FakeLocationTracker();
  final container = ProviderContainer(
    overrides: [
      locationTrackerProvider.overrideWithValue(tracker),
      if (repository != null)
        workoutRepositoryProvider.overrideWithValue(repository),
    ],
  );

  addTearDown(container.dispose);
  addTearDown(tracker.dispose);
  return container;
}

class FakeLocationTracker implements LocationTracker {
  FakeLocationTracker({
    this.initialAvailability = LocationTrackingAvailability.available,
    LocationTrackingAvailability? requestedAvailability,
  }) : requestedAvailability = requestedAvailability ?? initialAvailability {
    _positions = StreamController<LocationFix>.broadcast(
      sync: true,
      onListen: () => listenCount += 1,
      onCancel: () => cancelCount += 1,
    );
  }

  final LocationTrackingAvailability initialAvailability;
  final LocationTrackingAvailability requestedAvailability;
  late final StreamController<LocationFix> _positions;
  int checkAvailabilityCount = 0;
  int requestPermissionCount = 0;
  int listenCount = 0;
  int cancelCount = 0;

  @override
  Future<LocationTrackingAvailability> checkAvailability() async {
    checkAvailabilityCount += 1;
    return initialAvailability;
  }

  @override
  Future<LocationTrackingAvailability> requestPermission() async {
    requestPermissionCount += 1;
    return requestedAvailability;
  }

  @override
  Stream<LocationFix> get positionStream {
    return _positions.stream;
  }

  void addPosition(LocationFix position) {
    _positions.add(position);
  }

  void addError(Object error) {
    _positions.addError(error);
  }

  Future<void> dispose() {
    return _positions.close();
  }
}

class FakeWorkoutRepository implements WorkoutRepository {
  final workouts = <Workout>[];
  final routePoints = <RoutePoint>[];
  int _nextWorkoutId = 1;

  @override
  Future<int> insertWorkout(Workout workout) async {
    final id = _nextWorkoutId++;
    workouts.add(
      Workout(
        id: id,
        startedAt: workout.startedAt,
        duration: workout.duration,
        distanceMeters: workout.distanceMeters,
      ),
    );
    return id;
  }

  @override
  Future<void> insertRoutePoints(List<RoutePoint> routePoints) async {
    this.routePoints.addAll(routePoints);
  }

  @override
  Future<int> saveWorkoutWithRoutePoints(
    Workout workout,
    List<RoutePoint> Function(int workoutId) routePointsForWorkout,
  ) async {
    final workoutId = await insertWorkout(workout);
    await insertRoutePoints(routePointsForWorkout(workoutId));
    return workoutId;
  }

  @override
  Future<void> deleteWorkout(int workoutId) async {
    workouts.removeWhere((workout) => workout.id == workoutId);
    routePoints.removeWhere((point) => point.workoutId == workoutId);
  }

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
}
