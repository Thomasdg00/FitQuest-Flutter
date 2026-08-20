import 'package:flutter_test/flutter_test.dart';

import 'package:fitquest/src/domain/workout/route_point.dart';
import 'package:fitquest/src/map/presentation/live_route_map_data.dart';
import 'package:fitquest/src/tracking/domain/tracking_route_point.dart';

void main() {
  test('route points convert to LatLng coordinates', () {
    final startedAt = DateTime.utc(2026, 1, 1, 8);
    final path = trackingRoutePointsToLatLng([
      TrackingRoutePoint(
        latitude: 43.6158,
        longitude: 13.5189,
        timestamp: startedAt,
      ),
      TrackingRoutePoint(
        latitude: 43.6160,
        longitude: 13.5191,
        timestamp: startedAt.add(const Duration(seconds: 10)),
      ),
    ]);

    expect(path, hasLength(2));
    expect(path.first.latitude, 43.6158);
    expect(path.first.longitude, 13.5189);
    expect(path.last.latitude, 43.6160);
    expect(path.last.longitude, 13.5191);
  });

  test('saved route points convert to LatLng coordinates', () {
    final path = savedRoutePointsToLatLng([
      RoutePoint(
        id: 1,
        workoutId: 9,
        latitude: 43.6158,
        longitude: 13.5189,
        timestamp: DateTime.utc(2026, 1, 1, 8),
      ),
      RoutePoint(
        id: 2,
        workoutId: 9,
        latitude: 43.6162,
        longitude: 13.5195,
        timestamp: DateTime.utc(2026, 1, 1, 8, 1),
      ),
    ]);

    expect(path, hasLength(2));
    expect(path.first.latitude, 43.6158);
    expect(path.first.longitude, 13.5189);
    expect(path.last.latitude, 43.6162);
    expect(path.last.longitude, 13.5195);
  });

  test('empty route uses fallback camera and no polyline', () {
    final mapData = buildLiveRouteMapData(const []);

    expect(mapData.path, isEmpty);
    expect(mapData.polylines, isEmpty);
    expect(mapData.latestPosition, isNull);
    expect(mapData.initialCameraPosition.target.latitude, 43.6158);
    expect(mapData.initialCameraPosition.target.longitude, 13.5189);
    expect(mapData.initialCameraPosition.zoom, fallbackCameraZoom);
  });

  test('route points convert to LatLng path and one active polyline', () {
    final startedAt = DateTime.utc(2026, 1, 1, 8);
    final mapData = buildLiveRouteMapData([
      TrackingRoutePoint(
        latitude: 43.6158,
        longitude: 13.5189,
        timestamp: startedAt,
      ),
      TrackingRoutePoint(
        latitude: 43.6160,
        longitude: 13.5191,
        timestamp: startedAt.add(const Duration(seconds: 10)),
      ),
    ]);

    expect(mapData.path, hasLength(2));
    expect(mapData.path.first.latitude, 43.6158);
    expect(mapData.path.first.longitude, 13.5189);
    expect(mapData.latestPosition, mapData.path.last);
    expect(mapData.initialCameraPosition.target, mapData.path.last);
    expect(mapData.initialCameraPosition.zoom, activeRouteCameraZoom);
    expect(mapData.polylines, hasLength(1));

    final polyline = mapData.polylines.single;
    expect(polyline.polylineId.value, activeRoutePolylineId);
    expect(polyline.points, mapData.path);
    expect(polyline.width, 5);
  });

  test('saved route centers camera on route bounds', () {
    final mapData = buildSavedRouteMapData([
      RoutePoint(
        id: 1,
        workoutId: 9,
        latitude: 43.6158,
        longitude: 13.5189,
        timestamp: DateTime.utc(2026, 1, 1, 8),
      ),
      RoutePoint(
        id: 2,
        workoutId: 9,
        latitude: 43.6162,
        longitude: 13.5195,
        timestamp: DateTime.utc(2026, 1, 1, 8, 1),
      ),
    ]);

    expect(mapData.path, hasLength(2));
    expect(mapData.latestPosition, mapData.path.last);
    expect(
      mapData.initialCameraPosition.target.latitude,
      closeTo(43.6160, 0.000001),
    );
    expect(
      mapData.initialCameraPosition.target.longitude,
      closeTo(13.5192, 0.000001),
    );
    expect(mapData.initialCameraPosition.zoom, savedRouteCameraZoom);
    expect(mapData.polylines, hasLength(1));
  });

  test('saved one-point route uses point as camera target', () {
    final mapData = buildSavedRouteMapData([
      RoutePoint(
        id: 1,
        workoutId: 9,
        latitude: 43.6158,
        longitude: 13.5189,
        timestamp: DateTime.utc(2026, 1, 1, 8),
      ),
    ]);

    expect(mapData.path, hasLength(1));
    expect(mapData.latestPosition, mapData.path.single);
    expect(mapData.initialCameraPosition.target, mapData.path.single);
    expect(mapData.polylines, hasLength(1));
  });
}
