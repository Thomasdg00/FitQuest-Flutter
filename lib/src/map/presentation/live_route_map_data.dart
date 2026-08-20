import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/workout/route_point.dart';
import '../../tracking/domain/tracking_route_point.dart';

const activeRoutePolylineId = 'active-route';
const fallbackCameraTarget = LatLng(43.6158, 13.5189);
const fallbackCameraZoom = 13.0;
const activeRouteCameraZoom = 16.0;
const savedRouteCameraZoom = 15.0;
const activeRouteColor = Color(0xFF2E7D32);

class LiveRouteMapData {
  const LiveRouteMapData({
    required this.path,
    required this.polylines,
    required this.initialCameraPosition,
    required this.latestPosition,
  });

  final List<LatLng> path;
  final Set<Polyline> polylines;
  final CameraPosition initialCameraPosition;
  final LatLng? latestPosition;
}

List<LatLng> trackingRoutePointsToLatLng(
  Iterable<TrackingRoutePoint> routePoints,
) {
  return List<LatLng>.unmodifiable(
    routePoints.map((point) => LatLng(point.latitude, point.longitude)),
  );
}

List<LatLng> savedRoutePointsToLatLng(Iterable<RoutePoint> routePoints) {
  return List<LatLng>.unmodifiable(
    routePoints.map((point) => LatLng(point.latitude, point.longitude)),
  );
}

LiveRouteMapData buildLiveRouteMapData(
  Iterable<TrackingRoutePoint> routePoints,
) {
  final path = trackingRoutePointsToLatLng(routePoints);
  final latestPosition = path.isEmpty ? null : path.last;

  return _buildRouteMapData(
    path: path,
    cameraTarget: latestPosition,
    routeZoom: activeRouteCameraZoom,
  );
}

LiveRouteMapData buildSavedRouteMapData(Iterable<RoutePoint> routePoints) {
  final path = savedRoutePointsToLatLng(routePoints);

  return _buildRouteMapData(
    path: path,
    cameraTarget: _routeCenter(path),
    routeZoom: savedRouteCameraZoom,
  );
}

LiveRouteMapData _buildRouteMapData({
  required List<LatLng> path,
  required LatLng? cameraTarget,
  required double routeZoom,
}) {
  final latestPosition = path.isEmpty ? null : path.last;

  return LiveRouteMapData(
    path: path,
    polylines: _buildRoutePolyline(path),
    initialCameraPosition: CameraPosition(
      target: cameraTarget ?? fallbackCameraTarget,
      zoom: cameraTarget == null ? fallbackCameraZoom : routeZoom,
    ),
    latestPosition: latestPosition,
  );
}

LatLng? _routeCenter(List<LatLng> path) {
  if (path.isEmpty) {
    return null;
  }

  var minLatitude = path.first.latitude;
  var maxLatitude = path.first.latitude;
  var minLongitude = path.first.longitude;
  var maxLongitude = path.first.longitude;

  for (final point in path.skip(1)) {
    if (point.latitude < minLatitude) {
      minLatitude = point.latitude;
    }
    if (point.latitude > maxLatitude) {
      maxLatitude = point.latitude;
    }
    if (point.longitude < minLongitude) {
      minLongitude = point.longitude;
    }
    if (point.longitude > maxLongitude) {
      maxLongitude = point.longitude;
    }
  }

  return LatLng(
    (minLatitude + maxLatitude) / 2,
    (minLongitude + maxLongitude) / 2,
  );
}

Set<Polyline> _buildRoutePolyline(List<LatLng> path) {
  if (path.isEmpty) {
    return const <Polyline>{};
  }

  return {
    Polyline(
      polylineId: const PolylineId(activeRoutePolylineId),
      points: path,
      color: activeRouteColor,
      width: 5,
    ),
  };
}
