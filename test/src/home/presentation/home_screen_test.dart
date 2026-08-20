import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitquest/src/data/workout/workout_repository_provider.dart';
import 'package:fitquest/src/domain/workout/route_point.dart';
import 'package:fitquest/src/domain/workout/workout.dart';
import 'package:fitquest/src/domain/workout/workout_repository.dart';
import 'package:fitquest/src/goals/application/weekly_goal_providers.dart';
import 'package:fitquest/src/goals/domain/weekly_goal.dart';
import 'package:fitquest/src/goals/domain/weekly_goal_repository.dart';
import 'package:fitquest/src/home/application/home_providers.dart';
import 'package:fitquest/src/home/presentation/home_screen.dart';

void main() {
  testWidgets('HomeScreen shows empty goal and activity states', (
    tester,
  ) async {
    await _pumpHome(tester, goalRepository: FakeWeeklyGoalRepository());

    expect(find.text('Obiettivo settimanale'), findsOneWidget);
    expect(find.text('Nessun obiettivo settimanale impostato'), findsOneWidget);
    expect(find.text('Imposta obiettivo'), findsOneWidget);
    expect(find.text('Avvia attività'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Attività recente'), 120);
    await tester.pump();

    expect(find.text('Attività recente'), findsOneWidget);
    expect(find.text('Nessuna attività registrata'), findsOneWidget);
    expect(find.text('Avvia la tua prima attività.'), findsOneWidget);
  });

  testWidgets('HomeScreen start tracking CTA calls callback', (tester) async {
    var startTrackingTapped = false;

    await _pumpHome(
      tester,
      goalRepository: FakeWeeklyGoalRepository(),
      onStartTracking: () {
        startTrackingTapped = true;
      },
    );

    await tester.tap(find.byKey(const Key('home-start-tracking-button')));
    await tester.pump();

    expect(startTrackingTapped, isTrue);
  });

  testWidgets('HomeScreen opens set goal dialog', (tester) async {
    final goalRepository = FakeWeeklyGoalRepository();
    await _pumpHome(tester, goalRepository: goalRepository);

    await _openGoalDialog(tester, 'Imposta obiettivo');

    expect(find.text('Imposta obiettivo'), findsWidgets);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(goalRepository.goals, isEmpty);
  });

  testWidgets('HomeScreen saves a valid weekly goal in meters', (tester) async {
    final goalRepository = FakeWeeklyGoalRepository();
    await _pumpHome(tester, goalRepository: goalRepository);

    await _openGoalDialog(tester, 'Imposta obiettivo');
    await tester.enterText(find.byType(TextField), '5.5');
    await tester.tap(find.widgetWithText(TextButton, 'Salva'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.byType(AlertDialog), findsNothing);
    expect(goalRepository.goals.single.targetDistanceMeters, 5500);
    expect(find.text('5,50 km obiettivo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HomeScreen saves after the weekly goal dialog closes', (
    tester,
  ) async {
    final goalRepository = FakeWeeklyGoalRepository();
    await _pumpHome(tester, goalRepository: goalRepository);

    await _openGoalDialog(tester, 'Imposta obiettivo');
    await tester.enterText(find.byType(TextField), '6');
    await tester.tap(find.widgetWithText(TextButton, 'Salva'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.byType(AlertDialog), findsNothing);
    expect(goalRepository.goals.single.targetDistanceMeters, 6000);
    expect(find.text('6,00 km obiettivo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HomeScreen accepts comma decimal weekly goal input', (
    tester,
  ) async {
    final goalRepository = FakeWeeklyGoalRepository();
    await _pumpHome(tester, goalRepository: goalRepository);

    await _openGoalDialog(tester, 'Imposta obiettivo');
    await tester.enterText(find.byType(TextField), '2,5');
    await tester.tap(find.widgetWithText(TextButton, 'Salva'));
    await tester.pump();
    await tester.pump();

    expect(goalRepository.goals.single.targetDistanceMeters, 2500);
    expect(find.text('2,50 km obiettivo'), findsOneWidget);
  });

  testWidgets('HomeScreen renders weekly goal progress', (tester) async {
    await _pumpHome(
      tester,
      goalRepository: FakeWeeklyGoalRepository(
        goals: [
          WeeklyGoal(
            id: 1,
            weekStartDate: DateTime(2026, 1, 5),
            targetDistanceMeters: 10000,
          ),
        ],
      ),
      workoutRepository: FakeWorkoutRepository(
        workouts: [
          Workout(
            id: 1,
            startedAt: DateTime(2026, 1, 7, 9),
            duration: const Duration(minutes: 30),
            distanceMeters: 4000,
          ),
        ],
      ),
    );

    expect(find.text('10,00 km obiettivo'), findsOneWidget);
    expect(find.text('Modifica obiettivo'), findsOneWidget);
    expect(find.text('4,00 km percorsi'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.text('6,00 km rimanenti'), findsOneWidget);
  });

  testWidgets('HomeScreen opens edit goal dialog with current target', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      goalRepository: FakeWeeklyGoalRepository(
        goals: [
          WeeklyGoal(
            id: 1,
            weekStartDate: DateTime(2026, 1, 5),
            targetDistanceMeters: 10000,
          ),
        ],
      ),
    );

    await _openGoalDialog(tester, 'Modifica obiettivo');

    expect(find.text('Modifica obiettivo settimanale'), findsOneWidget);
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.controller.text, '10');
  });

  testWidgets('HomeScreen updates an existing weekly goal', (tester) async {
    final goalRepository = FakeWeeklyGoalRepository(
      goals: [
        WeeklyGoal(
          id: 1,
          weekStartDate: DateTime(2026, 1, 5),
          targetDistanceMeters: 10000,
        ),
      ],
    );
    await _pumpHome(tester, goalRepository: goalRepository);

    await _openGoalDialog(tester, 'Modifica obiettivo');
    await tester.enterText(find.byType(TextField), '7.25');
    await tester.tap(find.widgetWithText(TextButton, 'Salva'));
    await tester.pump();
    await tester.pump();

    expect(goalRepository.goals.single.targetDistanceMeters, 7250);
    expect(find.text('7,25 km obiettivo'), findsOneWidget);
  });

  testWidgets('HomeScreen rejects empty weekly goal input', (tester) async {
    final goalRepository = FakeWeeklyGoalRepository();
    await _pumpHome(tester, goalRepository: goalRepository);

    await _openGoalDialog(tester, 'Imposta obiettivo');
    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.widgetWithText(TextButton, 'Salva'));
    await tester.pump();

    expect(goalRepository.goals, isEmpty);
    expect(find.text('Inserisci una distanza in km.'), findsOneWidget);
  });

  testWidgets('HomeScreen rejects invalid weekly goal input', (tester) async {
    final goalRepository = FakeWeeklyGoalRepository();
    await _pumpHome(tester, goalRepository: goalRepository);

    await _openGoalDialog(tester, 'Imposta obiettivo');
    await tester.enterText(find.byType(TextField), 'NaN');
    await tester.tap(find.widgetWithText(TextButton, 'Salva'));
    await tester.pump();

    expect(goalRepository.goals, isEmpty);
    expect(find.text('Inserisci una distanza valida.'), findsOneWidget);
  });

  testWidgets('HomeScreen rejects zero weekly goal input', (tester) async {
    final goalRepository = FakeWeeklyGoalRepository();
    await _pumpHome(tester, goalRepository: goalRepository);

    await _openGoalDialog(tester, 'Imposta obiettivo');
    await tester.enterText(find.byType(TextField), '0');
    await tester.tap(find.widgetWithText(TextButton, 'Salva'));
    await tester.pump();

    expect(goalRepository.goals, isEmpty);
    expect(find.text('Inserisci una distanza maggiore di 0.'), findsOneWidget);
  });

  testWidgets('HomeScreen rejects negative weekly goal input', (tester) async {
    final goalRepository = FakeWeeklyGoalRepository();
    await _pumpHome(tester, goalRepository: goalRepository);

    await _openGoalDialog(tester, 'Imposta obiettivo');
    await tester.enterText(find.byType(TextField), '-2');
    await tester.tap(find.widgetWithText(TextButton, 'Salva'));
    await tester.pump();

    expect(goalRepository.goals, isEmpty);
    expect(find.text('Inserisci una distanza maggiore di 0.'), findsOneWidget);
  });

  testWidgets('HomeScreen shows latest workout summary', (tester) async {
    await _pumpHome(
      tester,
      goalRepository: FakeWeeklyGoalRepository(),
      workoutRepository: FakeWorkoutRepository(
        workouts: [
          Workout(
            id: 2,
            startedAt: DateTime(2026, 1, 8, 7, 30),
            duration: const Duration(minutes: 24, seconds: 15),
            distanceMeters: 5200,
          ),
          Workout(
            id: 1,
            startedAt: DateTime(2026, 1, 6, 18),
            duration: const Duration(minutes: 18),
            distanceMeters: 2500,
          ),
        ],
      ),
    );

    await tester.scrollUntilVisible(find.text('Ultima attività'), 120);
    await tester.pump();

    expect(find.text('Ultima attività'), findsOneWidget);
    expect(find.text('08/01/2026 07:30'), findsOneWidget);
    expect(find.text('Distanza'), findsOneWidget);
    expect(find.text('5,20 km'), findsOneWidget);
    expect(find.text('Durata'), findsOneWidget);
    expect(find.text('24 min 15 s'), findsOneWidget);
  });
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required FakeWeeklyGoalRepository goalRepository,
  FakeWorkoutRepository? workoutRepository,
  VoidCallback? onStartTracking,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentDateProvider.overrideWithValue(DateTime(2026, 1, 7, 12)),
        weeklyGoalRepositoryProvider.overrideWithValue(goalRepository),
        workoutRepositoryProvider.overrideWithValue(
          workoutRepository ?? FakeWorkoutRepository(),
        ),
      ],
      child: MaterialApp(home: HomeScreen(onStartTracking: onStartTracking)),
    ),
  );
  await tester.pump();
}

Future<void> _openGoalDialog(WidgetTester tester, String buttonLabel) async {
  await tester.tap(find.text(buttonLabel).first);
  await tester.pump();
}

class FakeWeeklyGoalRepository implements WeeklyGoalRepository {
  FakeWeeklyGoalRepository({List<WeeklyGoal> goals = const []})
    : goals = [...goals];

  final List<WeeklyGoal> goals;

  @override
  Future<WeeklyGoal?> getWeeklyGoalForWeek(DateTime weekStartDate) async {
    for (final goal in goals) {
      if (goal.weekStartDate == weekStartDate) {
        return goal;
      }
    }
    return null;
  }

  @override
  Future<void> setWeeklyGoal(WeeklyGoal goal) async {
    goals.removeWhere((item) => item.weekStartDate == goal.weekStartDate);
    goals.add(
      WeeklyGoal(
        id: goal.id ?? goals.length + 1,
        weekStartDate: goal.weekStartDate,
        targetDistanceMeters: goal.targetDistanceMeters,
      ),
    );
  }
}

class FakeWorkoutRepository implements WorkoutRepository {
  FakeWorkoutRepository({this.workouts = const []});

  final List<Workout> workouts;

  @override
  Future<int> insertWorkout(Workout workout) {
    throw UnimplementedError('Home tests do not insert workouts.');
  }

  @override
  Future<void> insertRoutePoints(List<RoutePoint> routePoints) {
    throw UnimplementedError('Home tests do not insert route points.');
  }

  @override
  Future<int> saveWorkoutWithRoutePoints(
    Workout workout,
    List<RoutePoint> Function(int workoutId) routePointsForWorkout,
  ) {
    throw UnimplementedError('Home tests do not save workouts.');
  }

  @override
  Future<List<RoutePoint>> getRoutePointsForWorkout(int workoutId) async {
    return const [];
  }

  @override
  Future<List<Workout>> getWorkouts() async {
    return workouts;
  }

  @override
  Future<void> deleteWorkout(int workoutId) {
    throw UnimplementedError('Tests do not delete workouts.');
  }
}
