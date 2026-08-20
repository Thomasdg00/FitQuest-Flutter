import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitquest/src/data/workout/workout_repository_provider.dart';
import 'package:fitquest/src/domain/workout/route_point.dart';
import 'package:fitquest/src/domain/workout/workout.dart';
import 'package:fitquest/src/domain/workout/workout_repository.dart';
import 'package:fitquest/src/history/application/history_providers.dart';
import 'package:fitquest/src/map/presentation/tracking_map.dart';
import 'package:fitquest/src/tracking/application/tracking_providers.dart';
import 'package:fitquest/src/tracking/application/tracking_save_result.dart';
import 'package:fitquest/src/tracking/application/tracking_state.dart';
import 'package:fitquest/src/tracking/domain/location_fix.dart';
import 'package:fitquest/src/tracking/domain/location_tracker.dart';
import 'package:fitquest/src/tracking/presentation/tracking_screen.dart';

const _trackingStatusTextKey = Key('tracking-status-text');
const _trackingStopButtonKey = Key('tracking-stop-button');
const _trackingFeedbackKey = Key('tracking-feedback-message');
const _trackingMapPlaceholderKey = Key('tracking-map-placeholder');

void main() {
  testWidgets('Track screen starts in stopped state', (tester) async {
    await _pumpTrackingScreen(tester);

    expect(find.text('Stato'), findsOneWidget);
    expect(find.text('Ferma'), findsOneWidget);
    expect(find.text('00:00:00'), findsOneWidget);
    expect(find.text('0 m'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Avvia attività'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pausa'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Riprendi'), findsNothing);
    expect(find.byKey(_trackingStopButtonKey), findsNothing);
  });

  testWidgets('Track screen renders without native map initialization', (
    tester,
  ) async {
    await _pumpTrackingScreen(tester);

    expect(find.byKey(_trackingMapPlaceholderKey), findsOneWidget);
    expect(find.byKey(const Key('tracking-google-map')), findsNothing);
    expect(find.text('Anteprima mappa non disponibile'), findsOneWidget);
  });

  testWidgets('Start button changes UI to running', (tester) async {
    await _pumpTrackingScreen(tester);

    await _tapAndPumpUntilVisible(
      tester,
      find.widgetWithText(FilledButton, 'Avvia attività'),
      () => _statusText(tester) == 'In corso',
    );
    await tester.pump();

    _expectStatusText(tester, 'In corso');
    expect(find.widgetWithText(FilledButton, 'Avvia attività'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Pausa'), findsOneWidget);
    expect(find.byKey(_trackingStopButtonKey), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Termina'), findsOneWidget);
  });

  testWidgets('Elapsed time updates while running without GPS points', (
    tester,
  ) async {
    var now = DateTime.utc(2026, 1, 1, 8);
    await _pumpTrackingScreen(tester, clock: () => now);

    await _tapAndPumpUntilVisible(
      tester,
      find.byKey(const Key('tracking-start-button')),
      () => _statusText(tester) == 'In corso',
    );
    await tester.pump();

    _expectElapsedText(tester, '00:00:00');
    expect(_trackingMapPointCount(tester), 0);

    now = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    _expectElapsedText(tester, '00:00:01');
    expect(_trackingMapPointCount(tester), 0);
  });

  testWidgets('Elapsed time does not continue increasing while paused', (
    tester,
  ) async {
    var now = DateTime.utc(2026, 1, 1, 8);
    await _pumpTrackingScreen(tester, clock: () => now);

    await _tapAndPumpUntilVisible(
      tester,
      find.byKey(const Key('tracking-start-button')),
      () => _statusText(tester) == 'In corso',
    );
    await tester.pump();

    now = now.add(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));
    _expectElapsedText(tester, '00:00:02');

    await tester.tap(find.widgetWithText(FilledButton, 'Pausa'));
    await tester.pump();
    _expectElapsedText(tester, '00:00:02');

    now = now.add(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 5));

    _expectElapsedText(tester, '00:00:02');
  });

  testWidgets('Pause and resume update visible controls', (tester) async {
    await _pumpTrackingScreen(tester);

    await _tapAndPumpUntilVisible(
      tester,
      find.widgetWithText(FilledButton, 'Avvia attività'),
      () => _statusText(tester) == 'In corso',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Pausa'));
    await tester.pump();

    expect(find.text('In pausa'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Riprendi'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pausa'), findsNothing);
    expect(find.byKey(_trackingStopButtonKey), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Riprendi'));
    await tester.pump();

    _expectStatusText(tester, 'In corso');
    expect(find.widgetWithText(FilledButton, 'Pausa'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Riprendi'), findsNothing);
  });

  testWidgets('Stop returns the screen to stopped state', (tester) async {
    final tracker = await _pumpTrackingScreen(
      tester,
      repository: FakeWorkoutRepository(),
    );

    await _tapAndPumpUntilVisible(
      tester,
      find.widgetWithText(FilledButton, 'Avvia attività'),
      () => _statusText(tester) == 'In corso',
    );
    await tester.pump();
    await _tapAndPumpUntilVisible(
      tester,
      find.byKey(_trackingStopButtonKey),
      () => _statusText(tester) == 'Ferma',
    );

    _expectStatusText(tester, 'Ferma');
    _expectElapsedText(tester, '00:00:00');
    expect(find.widgetWithText(FilledButton, 'Avvia attività'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pausa'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Riprendi'), findsNothing);
    expect(find.byKey(_trackingStopButtonKey), findsNothing);
    expect(tracker.cancelCount, 1);
  });

  testWidgets('GPS positions update route data while running', (tester) async {
    final tracker = await _pumpTrackingScreen(tester);

    await _tapAndPumpUntilVisible(
      tester,
      find.widgetWithText(FilledButton, 'Avvia attività'),
      () => _statusText(tester) == 'In corso',
    );
    await tester.pump();
    await _addLocationAndPumpUntilVisible(
      tester,
      tracker,
      _locationFix(0),
      () => _trackingMapPointCount(tester) == 1,
    );

    expect(_trackingMapPointCount(tester), 1);
    expect(find.text('1 punto'), findsNothing);
  });

  testWidgets('Track screen formats kilometer distance with comma decimal', (
    tester,
  ) async {
    final tracker = await _pumpTrackingScreen(tester);

    await _tapAndPumpUntilVisible(
      tester,
      find.widgetWithText(FilledButton, 'Avvia attività'),
      () => _statusText(tester) == 'In corso',
    );
    await tester.pump();
    await _addLocationAndPumpUntilVisible(
      tester,
      tracker,
      _kilometerLocationFix(0),
      () => _trackingMapPointCount(tester) == 1,
    );
    await _addLocationAndPumpUntilVisible(
      tester,
      tracker,
      _kilometerLocationFix(1),
      () => find.text('1,20 km').evaluate().isNotEmpty,
    );

    expect(find.text('1,20 km'), findsOneWidget);
  });

  testWidgets('route data does not enable map user location layer', (
    tester,
  ) async {
    final tracker = await _pumpTrackingScreen(tester);

    await _tapAndPumpUntilVisible(
      tester,
      find.widgetWithText(FilledButton, 'Avvia attività'),
      () => _statusText(tester) == 'In corso',
    );
    await tester.pump();
    await _addLocationAndPumpUntilVisible(
      tester,
      tracker,
      _locationFix(0),
      () => _trackingMapPointCount(tester) == 1,
    );

    final map = tester.widget<TrackingMap>(find.byType(TrackingMap));

    expect(map.showUserLocation, isFalse);
    expect(_trackingMapPointCount(tester), 1);
    expect(find.text('Anteprima mappa non disponibile'), findsOneWidget);
  });

  testWidgets('Stop with GPS route points saves and shows feedback', (
    tester,
  ) async {
    final repository = FakeWorkoutRepository();
    final tracker = await _pumpTrackingScreen(tester, repository: repository);

    await _tapAndPumpUntilVisible(
      tester,
      find.widgetWithText(FilledButton, 'Avvia attività'),
      () => _statusText(tester) == 'In corso',
    );
    await tester.pump();
    await _addLocationAndPumpUntilVisible(
      tester,
      tracker,
      _locationFix(0),
      () => _trackingMapPointCount(tester) == 1,
    );
    await _addLocationAndPumpUntilVisible(
      tester,
      tracker,
      _locationFix(1),
      () => _trackingMapPointCount(tester) == 2,
    );
    await _tapAndPumpUntilVisible(
      tester,
      find.byKey(_trackingStopButtonKey),
      () => _feedbackText(tester) == 'Attività salvata.',
    );

    _expectStatusText(tester, 'Ferma');
    _expectFeedbackText(tester, 'Attività salvata.');
    expect(repository.workouts, hasLength(1));
    expect(repository.routePoints, hasLength(2));
    expect(
      repository.routePoints.every((point) => point.workoutId == 1),
      isTrue,
    );
  });

  testWidgets('Stop with empty session does not save and shows feedback', (
    tester,
  ) async {
    final repository = FakeWorkoutRepository();
    await _pumpTrackingScreen(tester, repository: repository);

    await _tapAndPumpUntilVisible(
      tester,
      find.widgetWithText(FilledButton, 'Avvia attività'),
      () => _statusText(tester) == 'In corso',
    );
    await tester.pump();
    await _tapAndPumpUntilVisible(
      tester,
      find.byKey(_trackingStopButtonKey),
      () => _feedbackText(tester) == 'Attività vuota non salvata.',
    );

    _expectStatusText(tester, 'Ferma');
    _expectFeedbackText(tester, 'Attività vuota non salvata.');
    expect(repository.workouts, isEmpty);
    expect(repository.routePoints, isEmpty);
  });

  testWidgets('Save failure shows feedback', (tester) async {
    final tracker = await _pumpTrackingScreen(
      tester,
      repository: FakeWorkoutRepository(failInserts: true),
    );

    await _tapAndPumpUntilVisible(
      tester,
      find.widgetWithText(FilledButton, 'Avvia attività'),
      () => _statusText(tester) == 'In corso',
    );
    await tester.pump();
    await _addLocationAndPumpUntilVisible(
      tester,
      tracker,
      _locationFix(0),
      () => _trackingMapPointCount(tester) == 1,
    );
    await _tapAndPumpUntilVisible(
      tester,
      find.byKey(_trackingStopButtonKey),
      () => _feedbackText(tester) == 'Impossibile salvare l\'attività.',
    );

    _expectFeedbackText(tester, 'Impossibile salvare l\'attività.');
    _expectStatusText(tester, 'Ferma');
  });

  test('Stop from stopped remains safe through provider', () async {
    final repository = FakeWorkoutRepository();
    final container = _trackingContainer(repository: repository);

    final notifier = container.read(trackingControllerProvider.notifier);

    final result = await notifier.stopAndSave();

    expect(result.status, TrackingSaveStatus.notSaved);
    expect(
      container.read(trackingControllerProvider).status,
      TrackingStatus.stopped,
    );
    expect(repository.workouts, isEmpty);
  });

  test('stopAndSave persists workout and linked route points', () async {
    final repository = FakeWorkoutRepository();
    final tracker = FakeLocationTracker();
    final container = _trackingContainer(
      repository: repository,
      locationTracker: tracker,
    );
    final notifier = container.read(trackingControllerProvider.notifier);

    await notifier.start();
    tracker.addPosition(_locationFix(0));
    tracker.addPosition(_locationFix(1));
    final result = await notifier.stopAndSave();

    expect(result.status, TrackingSaveStatus.saved);
    expect(result.workoutId, 1);
    expect(result.routePointCount, 2);
    expect(repository.workouts, hasLength(1));
    expect(repository.workouts.single.startedAt.isUtc, isTrue);
    expect(repository.routePoints, hasLength(2));
    expect(
      repository.routePoints.every((point) => point.workoutId == 1),
      isTrue,
    );
    expect(
      repository.routePoints.every((point) => point.timestamp.isUtc),
      isTrue,
    );
  });

  test('History provider can read workout saved by stopAndSave', () async {
    final repository = FakeWorkoutRepository();
    final tracker = FakeLocationTracker();
    final container = _trackingContainer(
      repository: repository,
      locationTracker: tracker,
    );
    final notifier = container.read(trackingControllerProvider.notifier);

    await notifier.start();
    tracker.addPosition(_locationFix(0));
    await notifier.stopAndSave();

    final workouts = await container.read(workoutHistoryProvider.future);

    expect(workouts, hasLength(1));
    expect(workouts.single.id, 1);
  });

  test('stopAndSave handles empty sessions without saving', () async {
    final repository = FakeWorkoutRepository();
    final container = _trackingContainer(repository: repository);
    final notifier = container.read(trackingControllerProvider.notifier);

    await notifier.start();
    final result = await notifier.stopAndSave();

    expect(result.status, TrackingSaveStatus.notSaved);
    expect(result.message, 'Attività vuota non salvata.');
    expect(repository.workouts, isEmpty);
    expect(repository.routePoints, isEmpty);
  });

  test('stopAndSave reports save failures', () async {
    final repository = FakeWorkoutRepository(failInserts: true);
    final tracker = FakeLocationTracker();
    final container = _trackingContainer(
      repository: repository,
      locationTracker: tracker,
    );
    final notifier = container.read(trackingControllerProvider.notifier);

    await notifier.start();
    tracker.addPosition(_locationFix(0));
    final result = await notifier.stopAndSave();

    expect(result.status, TrackingSaveStatus.failed);
    expect(result.message, 'Impossibile salvare l\'attività.');
    expect(
      container.read(trackingControllerProvider).status,
      TrackingStatus.stopped,
    );
  });
}

Future<FakeLocationTracker> _pumpTrackingScreen(
  WidgetTester tester, {
  WorkoutRepository? repository,
  DateTime Function()? clock,
}) async {
  final tracker = FakeLocationTracker();
  addTearDown(tracker.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        trackingMapEnabledProvider.overrideWithValue(false),
        locationTrackerProvider.overrideWithValue(tracker),
        if (clock != null) trackingClockProvider.overrideWithValue(clock),
        if (repository != null)
          workoutRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(home: TrackingScreen(showHistoryButton: false)),
    ),
  );
  await tester.pump();
  return tracker;
}

ProviderContainer _trackingContainer({
  required WorkoutRepository repository,
  FakeLocationTracker? locationTracker,
}) {
  final tracker = locationTracker ?? FakeLocationTracker();
  final container = ProviderContainer(
    overrides: [
      trackingMapEnabledProvider.overrideWithValue(false),
      locationTrackerProvider.overrideWithValue(tracker),
      workoutRepositoryProvider.overrideWithValue(repository),
    ],
  );

  addTearDown(() async {
    container.dispose();
    await tracker.dispose();
  });
  return container;
}

Future<void> _tapAndPumpUntilVisible(
  WidgetTester tester,
  Finder tapTarget,
  Object expected, {
  int maxPumps = 10,
}) async {
  await tester.tap(tapTarget);
  await _pumpUntilVisible(tester, expected, maxPumps: maxPumps);
}

Future<void> _addLocationAndPumpUntilVisible(
  WidgetTester tester,
  FakeLocationTracker tracker,
  LocationFix position,
  Object expected, {
  int maxPumps = 10,
}) async {
  tracker.addPosition(position);
  await _pumpUntilVisible(tester, expected, maxPumps: maxPumps);
}

Future<void> _pumpUntilVisible(
  WidgetTester tester,
  Object expected, {
  required int maxPumps,
}) async {
  for (var pumpCount = 0; pumpCount < maxPumps; pumpCount += 1) {
    await tester.pump(const Duration(milliseconds: 50));
    if (_isVisible(tester, expected)) {
      await tester.pump(const Duration(milliseconds: 50));
      return;
    }
  }
}

bool _isVisible(WidgetTester tester, Object expected) {
  if (expected is Finder) {
    return expected.evaluate().isNotEmpty;
  }

  if (expected is bool Function()) {
    return expected();
  }

  throw ArgumentError.value(expected, 'expected');
}

void _expectStatusText(WidgetTester tester, String expected) {
  expect(
    find.byKey(_trackingStatusTextKey, skipOffstage: false),
    findsOneWidget,
  );
  expect(_statusText(tester), expected);
}

void _expectElapsedText(WidgetTester tester, String expected) {
  expect(_elapsedText(tester), expected);
}

int _trackingMapPointCount(WidgetTester tester) {
  return tester
      .widget<TrackingMap>(find.byType(TrackingMap))
      .routePoints
      .length;
}

LocationFix _locationFix(int index) {
  return LocationFix(
    latitude: 43.6158 + (index * 0.0002),
    longitude: 13.5189 + (index * 0.0002),
    timestamp: DateTime.utc(2026, 1, 1, 8, index),
  );
}

LocationFix _kilometerLocationFix(int index) {
  return LocationFix(
    latitude: 0,
    longitude: index == 0 ? 0 : 0.0108,
    timestamp: DateTime.utc(2026, 1, 1, 9, index),
  );
}

String? _statusText(WidgetTester tester) {
  final finder = find.byKey(_trackingStatusTextKey, skipOffstage: false);
  final elements = finder.evaluate();
  if (elements.isEmpty) {
    return null;
  }

  final widget = elements.single.widget;
  if (widget is Text) {
    return widget.data;
  }

  return null;
}

String? _elapsedText(WidgetTester tester) {
  final elapsedPattern = RegExp(r'^\d\d:\d\d:\d\d$');
  final matches = tester
      .widgetList<Text>(find.byType(Text))
      .map((widget) => widget.data)
      .whereType<String>()
      .where(elapsedPattern.hasMatch)
      .toList(growable: false);

  if (matches.isEmpty) {
    return null;
  }

  return matches.single;
}

void _expectFeedbackText(WidgetTester tester, String expected) {
  expect(find.byKey(_trackingFeedbackKey, skipOffstage: false), findsOneWidget);
  expect(_feedbackText(tester), expected);
}

String? _feedbackText(WidgetTester tester) {
  final finder = find.byKey(_trackingFeedbackKey, skipOffstage: false);
  final elements = finder.evaluate();
  if (elements.isEmpty) {
    return null;
  }

  final widget = elements.single.widget;
  if (widget is Text) {
    return widget.data;
  }

  return null;
}

class FakeLocationTracker implements LocationTracker {
  FakeLocationTracker() {
    _positions = StreamController<LocationFix>.broadcast(
      sync: true,
      onListen: () => listenCount += 1,
      onCancel: () => cancelCount += 1,
    );
  }

  late final StreamController<LocationFix> _positions;
  int listenCount = 0;
  int cancelCount = 0;

  @override
  Future<LocationTrackingAvailability> checkAvailability() async {
    return LocationTrackingAvailability.available;
  }

  @override
  Future<LocationTrackingAvailability> requestPermission() async {
    return LocationTrackingAvailability.available;
  }

  @override
  Stream<LocationFix> get positionStream {
    return _positions.stream;
  }

  void addPosition(LocationFix position) {
    _positions.add(position);
  }

  Future<void> dispose() async {
    await _positions.close();
  }
}

class FakeWorkoutRepository implements WorkoutRepository {
  FakeWorkoutRepository({this.failInserts = false});

  final bool failInserts;
  final workouts = <Workout>[];
  final routePoints = <RoutePoint>[];
  int _nextWorkoutId = 1;

  @override
  Future<int> insertWorkout(Workout workout) async {
    if (failInserts) {
      throw StateError('insert failed');
    }

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
    if (failInserts) {
      throw StateError('insert failed');
    }

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
  Future<List<Workout>> getWorkouts() async {
    return List.unmodifiable(workouts);
  }

  @override
  Future<List<RoutePoint>> getRoutePointsForWorkout(int workoutId) async {
    return routePoints
        .where((point) => point.workoutId == workoutId)
        .toList(growable: false);
  }

  @override
  Future<void> deleteWorkout(int workoutId) {
    throw UnimplementedError('Tests do not delete workouts.');
  }
}
