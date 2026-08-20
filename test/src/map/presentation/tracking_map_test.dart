import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitquest/src/domain/workout/route_point.dart';
import 'package:fitquest/src/map/presentation/tracking_map.dart';
import 'package:fitquest/src/tracking/domain/tracking_route_point.dart';

void main() {
  testWidgets('empty route renders map placeholder without native map', (
    tester,
  ) async {
    await _pumpTrackingMap(tester, routePoints: const []);

    expect(find.byKey(const Key('tracking-map-placeholder')), findsOneWidget);
    expect(find.byKey(const Key('tracking-google-map')), findsNothing);
    expect(find.text('Anteprima mappa non disponibile'), findsOneWidget);
  });

  testWidgets('non-empty route renders generic map placeholder', (
    tester,
  ) async {
    await _pumpTrackingMap(
      tester,
      routePoints: [
        TrackingRoutePoint(
          latitude: 43.6158,
          longitude: 13.5189,
          timestamp: DateTime.utc(2026, 1, 1, 8),
        ),
      ],
    );

    expect(find.text('Anteprima mappa non disponibile'), findsOneWidget);
  });

  testWidgets('route points do not enable user location by default', (
    tester,
  ) async {
    await _pumpTrackingMap(
      tester,
      routePoints: [
        TrackingRoutePoint(
          latitude: 43.6158,
          longitude: 13.5189,
          timestamp: DateTime.utc(2026, 1, 1, 8),
        ),
      ],
    );

    final map = tester.widget<TrackingMap>(find.byType(TrackingMap));

    expect(map.showUserLocation, isFalse);
    expect(find.text('Anteprima mappa non disponibile'), findsOneWidget);
  });

  testWidgets('completed route maps keep user location disabled', (
    tester,
  ) async {
    await _pumpCompletedRouteMap(
      tester,
      routePoints: [
        RoutePoint(
          id: 1,
          workoutId: 7,
          latitude: 43.6158,
          longitude: 13.5189,
          timestamp: DateTime.utc(2026, 1, 1, 8),
        ),
      ],
    );

    final map = tester.widget<CompletedRouteMap>(
      find.byType(CompletedRouteMap),
    );

    expect(map.showUserLocation, isFalse);
    expect(find.text('Anteprima mappa non disponibile'), findsOneWidget);
  });

  testWidgets('completed route map renders placeholder without native map', (
    tester,
  ) async {
    await _pumpCompletedRouteMap(
      tester,
      routePoints: [
        RoutePoint(
          id: 1,
          workoutId: 7,
          latitude: 43.6158,
          longitude: 13.5189,
          timestamp: DateTime.utc(2026, 1, 1, 8),
        ),
        RoutePoint(
          id: 2,
          workoutId: 7,
          latitude: 43.6160,
          longitude: 13.5191,
          timestamp: DateTime.utc(2026, 1, 1, 8, 1),
        ),
      ],
    );

    expect(
      find.byKey(const Key('completed-route-map-placeholder')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('completed-route-google-map')), findsNothing);
    expect(find.text('Anteprima mappa non disponibile'), findsOneWidget);
  });
}

Future<void> _pumpTrackingMap(
  WidgetTester tester, {
  required List<TrackingRoutePoint> routePoints,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [trackingMapEnabledProvider.overrideWithValue(false)],
      child: MaterialApp(
        home: Scaffold(body: TrackingMap(routePoints: routePoints)),
      ),
    ),
  );
}

Future<void> _pumpCompletedRouteMap(
  WidgetTester tester, {
  required List<RoutePoint> routePoints,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [trackingMapEnabledProvider.overrideWithValue(false)],
      child: MaterialApp(
        home: Scaffold(body: CompletedRouteMap(routePoints: routePoints)),
      ),
    ),
  );
}
