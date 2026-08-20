import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitquest/src/data/workout/workout_repository_provider.dart';
import 'package:fitquest/src/domain/workout/route_point.dart';
import 'package:fitquest/src/domain/workout/workout.dart';
import 'package:fitquest/src/domain/workout/workout_repository.dart';
import 'package:fitquest/src/history/presentation/history_screen.dart';
import 'package:fitquest/src/history/presentation/workout_detail_screen.dart';
import 'package:fitquest/src/map/presentation/tracking_map.dart';

void main() {
  testWidgets('HistoryScreen shows empty state when no workouts exist', (
    tester,
  ) async {
    await _pumpWithRepository(
      tester,
      repository: FakeWorkoutRepository(),
      child: const HistoryScreen(),
    );

    expect(find.text('Nessuna attività registrata'), findsOneWidget);
    expect(
      find.text('Le attività salvate appariranno qui dopo la registrazione.'),
      findsOneWidget,
    );
  });

  testWidgets('HistoryScreen renders saved workout summary', (tester) async {
    await _pumpWithRepository(
      tester,
      repository: FakeWorkoutRepository(
        workouts: [
          Workout(
            id: 7,
            startedAt: DateTime(2026, 1, 2, 8, 30),
            duration: const Duration(minutes: 42),
            distanceMeters: 6400,
          ),
        ],
      ),
      child: const HistoryScreen(),
    );

    expect(find.text('02/01/2026 08:30'), findsOneWidget);
    expect(find.text('42 min 00 s'), findsOneWidget);
    expect(find.text('6,40 km'), findsOneWidget);
  });

  testWidgets('WorkoutDetailScreen shows empty route state', (tester) async {
    await _pumpWithRepository(
      tester,
      repository: FakeWorkoutRepository(),
      child: WorkoutDetailScreen(
        workout: Workout(
          id: 3,
          startedAt: DateTime(2026, 1, 3, 9),
          duration: const Duration(minutes: 15),
          distanceMeters: 1200,
        ),
      ),
    );

    expect(
      find.text('Nessun percorso salvato per questa attività.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('completed-route-map-placeholder')),
      findsNothing,
    );
  });

  testWidgets('WorkoutDetailScreen shows delete action', (tester) async {
    await _pumpWithRepository(
      tester,
      repository: FakeWorkoutRepository(),
      child: WorkoutDetailScreen(
        workout: Workout(
          id: 5,
          startedAt: DateTime(2026, 1, 5, 7),
          duration: const Duration(minutes: 25),
          distanceMeters: 3100,
        ),
      ),
    );

    expect(find.byKey(const Key('delete-workout-button')), findsOneWidget);
    expect(find.byTooltip('Elimina attività'), findsOneWidget);
  });

  testWidgets('tapping delete opens confirmation dialog', (tester) async {
    await _pumpWithRepository(
      tester,
      repository: FakeWorkoutRepository(),
      child: WorkoutDetailScreen(
        workout: Workout(
          id: 5,
          startedAt: DateTime(2026, 1, 5, 7),
          duration: const Duration(minutes: 25),
          distanceMeters: 3100,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('delete-workout-button')));
    await tester.pumpAndSettle();

    expect(find.text('Eliminare attività?'), findsOneWidget);
    expect(
      find.text('Questa operazione eliminerà anche il percorso salvato.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('cancel-delete-workout-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('confirm-delete-workout-button')),
      findsOneWidget,
    );
    expect(find.text('Annulla'), findsOneWidget);
    expect(find.text('Elimina'), findsOneWidget);
  });

  testWidgets('canceling deletion keeps workout detail unchanged', (
    tester,
  ) async {
    final repository = FakeWorkoutRepository(
      workouts: [
        Workout(
          id: 5,
          startedAt: DateTime(2026, 1, 5, 7),
          duration: const Duration(minutes: 25),
          distanceMeters: 3100,
        ),
      ],
    );

    await _pumpWithRepository(
      tester,
      repository: repository,
      child: WorkoutDetailScreen(workout: repository.workouts.single),
    );

    await tester.tap(find.byKey(const Key('delete-workout-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cancel-delete-workout-button')));
    await tester.pumpAndSettle();

    expect(repository.deletedWorkoutIds, isEmpty);
    expect(find.text('Dettaglio attività'), findsOneWidget);
    expect(find.text('05/01/2026 07:00'), findsOneWidget);
  });

  testWidgets(
    'confirming deletion removes workout, returns to history, and shows feedback',
    (tester) async {
      final repository = FakeWorkoutRepository(
        workouts: [
          Workout(
            id: 5,
            startedAt: DateTime(2026, 1, 5, 7),
            duration: const Duration(minutes: 25),
            distanceMeters: 3100,
          ),
        ],
        routePointsByWorkoutId: {
          5: [
            RoutePoint(
              id: 1,
              workoutId: 5,
              latitude: 43.6158,
              longitude: 13.5189,
              timestamp: DateTime(2026, 1, 5, 7, 1),
            ),
          ],
        },
      );

      await _pumpWithRepository(
        tester,
        repository: repository,
        child: const HistoryScreen(),
      );

      await tester.tap(find.text('05/01/2026 07:00'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete-workout-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-delete-workout-button')));
      await tester.pumpAndSettle();

      expect(repository.deletedWorkoutIds, [5]);
      expect(repository.workouts, isEmpty);
      expect(repository.routePointsByWorkoutId.containsKey(5), isFalse);
      expect(find.text('Cronologia'), findsOneWidget);
      expect(find.text('05/01/2026 07:00'), findsNothing);
      expect(find.text('Nessuna attività registrata'), findsOneWidget);
      expect(find.text('Attività eliminata.'), findsOneWidget);
    },
  );

  testWidgets('deletion failure stays on detail and shows error feedback', (
    tester,
  ) async {
    final repository = FakeWorkoutRepository(
      failDeletes: true,
      workouts: [
        Workout(
          id: 5,
          startedAt: DateTime(2026, 1, 5, 7),
          duration: const Duration(minutes: 25),
          distanceMeters: 3100,
        ),
      ],
    );

    await _pumpWithRepository(
      tester,
      repository: repository,
      child: const HistoryScreen(),
    );

    await tester.tap(find.text('05/01/2026 07:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete-workout-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete-workout-button')));
    await tester.pumpAndSettle();

    expect(repository.deletedWorkoutIds, [5]);
    expect(repository.workouts, hasLength(1));
    expect(find.text('Dettaglio attività'), findsOneWidget);
    expect(find.text('05/01/2026 07:00'), findsOneWidget);
    expect(find.text("Impossibile eliminare l'attività."), findsOneWidget);
  });

  testWidgets('tapping a workout opens detail with route map placeholder', (
    tester,
  ) async {
    await _pumpWithRepository(
      tester,
      repository: FakeWorkoutRepository(
        workouts: [
          Workout(
            id: 4,
            startedAt: DateTime(2026, 1, 4, 10),
            duration: const Duration(minutes: 20),
            distanceMeters: 2300,
          ),
        ],
        routePointsByWorkoutId: {
          4: [
            RoutePoint(
              id: 1,
              workoutId: 4,
              latitude: 43.6158,
              longitude: 13.5189,
              timestamp: DateTime(2026, 1, 4, 10, 1),
            ),
            RoutePoint(
              id: 2,
              workoutId: 4,
              latitude: 43.6160,
              longitude: 13.5191,
              timestamp: DateTime(2026, 1, 4, 10, 2),
            ),
          ],
        },
      ),
      child: const HistoryScreen(),
    );

    await tester.tap(find.text('04/01/2026 10:00'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(
      find.byKey(const Key('completed-route-map-placeholder')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('completed-route-google-map')), findsNothing);
    expect(find.text('Anteprima mappa non disponibile'), findsOneWidget);
  });
}

Future<void> _pumpWithRepository(
  WidgetTester tester, {
  required FakeWorkoutRepository repository,
  required Widget child,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        trackingMapEnabledProvider.overrideWithValue(false),
        workoutRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(home: child),
    ),
  );
  await tester.pump();
}

class FakeWorkoutRepository implements WorkoutRepository {
  FakeWorkoutRepository({
    List<Workout> workouts = const [],
    Map<int, List<RoutePoint>> routePointsByWorkoutId = const {},
    this.failDeletes = false,
  }) : workouts = List<Workout>.of(workouts),
       routePointsByWorkoutId = routePointsByWorkoutId.map(
         (workoutId, points) =>
             MapEntry(workoutId, List<RoutePoint>.of(points)),
       );

  final List<Workout> workouts;
  final Map<int, List<RoutePoint>> routePointsByWorkoutId;
  final bool failDeletes;
  final deletedWorkoutIds = <int>[];

  @override
  Future<int> insertWorkout(Workout workout) {
    throw UnimplementedError('History tests do not insert workouts.');
  }

  @override
  Future<void> insertRoutePoints(List<RoutePoint> routePoints) {
    throw UnimplementedError('History tests do not insert route points.');
  }

  @override
  Future<int> saveWorkoutWithRoutePoints(
    Workout workout,
    List<RoutePoint> Function(int workoutId) routePointsForWorkout,
  ) {
    throw UnimplementedError('History tests do not save workouts.');
  }

  @override
  Future<List<Workout>> getWorkouts() async {
    return List.unmodifiable(workouts);
  }

  @override
  Future<List<RoutePoint>> getRoutePointsForWorkout(int workoutId) async {
    return List.unmodifiable(routePointsByWorkoutId[workoutId] ?? const []);
  }

  @override
  Future<void> deleteWorkout(int workoutId) async {
    deletedWorkoutIds.add(workoutId);
    if (failDeletes) {
      throw StateError('delete failed');
    }

    workouts.removeWhere((workout) => workout.id == workoutId);
    routePointsByWorkoutId.remove(workoutId);
  }
}
