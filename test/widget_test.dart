import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitquest/main.dart';
import 'package:fitquest/src/data/workout/workout_repository_provider.dart';
import 'package:fitquest/src/domain/workout/route_point.dart';
import 'package:fitquest/src/domain/workout/workout.dart';
import 'package:fitquest/src/domain/workout/workout_repository.dart';
import 'package:fitquest/src/goals/application/weekly_goal_providers.dart';
import 'package:fitquest/src/goals/domain/weekly_goal.dart';
import 'package:fitquest/src/goals/domain/weekly_goal_repository.dart';
import 'package:fitquest/src/home/application/home_providers.dart';
import 'package:fitquest/src/map/presentation/tracking_map.dart';

void main() {
  testWidgets('shows home screen and CTA navigates to tracking', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentDateProvider.overrideWithValue(DateTime(2026, 1, 7, 12)),
          weeklyGoalRepositoryProvider.overrideWithValue(
            FakeWeeklyGoalRepository(),
          ),
          workoutRepositoryProvider.overrideWithValue(FakeWorkoutRepository()),
          trackingMapEnabledProvider.overrideWithValue(false),
        ],
        child: const FitQuestApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Inizio'), findsWidgets);
    expect(find.text('Obiettivo settimanale'), findsOneWidget);
    expect(find.text('Nessun obiettivo settimanale impostato'), findsOneWidget);
    expect(find.text('Avvia attività'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-start-tracking-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Sessione corrente'), findsOneWidget);
    expect(find.text('Ferma'), findsOneWidget);
    expect(find.byKey(const Key('tracking-map-placeholder')), findsOneWidget);
    expect(find.byKey(const Key('tracking-start-button')), findsOneWidget);
  });
}

class FakeWeeklyGoalRepository implements WeeklyGoalRepository {
  @override
  Future<WeeklyGoal?> getWeeklyGoalForWeek(DateTime weekStartDate) async {
    return null;
  }

  @override
  Future<void> setWeeklyGoal(WeeklyGoal goal) async {}
}

class FakeWorkoutRepository implements WorkoutRepository {
  @override
  Future<int> insertWorkout(Workout workout) {
    throw UnimplementedError('Widget test does not insert workouts.');
  }

  @override
  Future<void> insertRoutePoints(List<RoutePoint> routePoints) {
    throw UnimplementedError('Widget test does not insert route points.');
  }

  @override
  Future<int> saveWorkoutWithRoutePoints(
    Workout workout,
    List<RoutePoint> Function(int workoutId) routePointsForWorkout,
  ) {
    throw UnimplementedError('Widget test does not save workouts.');
  }

  @override
  Future<List<RoutePoint>> getRoutePointsForWorkout(int workoutId) async {
    return const [];
  }

  @override
  Future<List<Workout>> getWorkouts() async {
    return const [];
  }

  @override
  Future<void> deleteWorkout(int workoutId) {
    throw UnimplementedError('Tests do not delete workouts.');
  }
}
