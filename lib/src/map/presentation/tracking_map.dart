import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/workout/route_point.dart';
import '../../tracking/domain/tracking_route_point.dart';
import 'live_route_map_data.dart';

final trackingMapEnabledProvider = Provider<bool>((ref) => true);

class TrackingMap extends StatelessWidget {
  const TrackingMap({
    required this.routePoints,
    this.showUserLocation = false,
    super.key,
  });

  final List<TrackingRoutePoint> routePoints;
  final bool showUserLocation;

  @override
  Widget build(BuildContext context) {
    return _RouteMap(
      mapData: buildLiveRouteMapData(routePoints),
      mapKey: const Key('tracking-google-map'),
      placeholderKey: const Key('tracking-map-placeholder'),
      followLatestPosition: true,
      showUserLocation: showUserLocation,
    );
  }
}

class CompletedRouteMap extends StatelessWidget {
  const CompletedRouteMap({required this.routePoints, super.key});

  final List<RoutePoint> routePoints;
  final bool showUserLocation = false;

  @override
  Widget build(BuildContext context) {
    return _RouteMap(
      mapData: buildSavedRouteMapData(routePoints),
      mapKey: const Key('completed-route-google-map'),
      placeholderKey: const Key('completed-route-map-placeholder'),
      followLatestPosition: false,
      showUserLocation: showUserLocation,
    );
  }
}

class _RouteMap extends ConsumerStatefulWidget {
  const _RouteMap({
    required this.mapData,
    required this.mapKey,
    required this.placeholderKey,
    required this.followLatestPosition,
    required this.showUserLocation,
  });

  final LiveRouteMapData mapData;
  final Key mapKey;
  final Key placeholderKey;
  final bool followLatestPosition;
  final bool showUserLocation;

  @override
  ConsumerState<_RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends ConsumerState<_RouteMap> {
  GoogleMapController? _mapController;
  LatLng? _lastCameraTarget;

  @override
  void didUpdateWidget(covariant _RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.followLatestPosition) {
      _moveCameraToLatest(widget.mapData.latestPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapEnabled = ref.watch(trackingMapEnabledProvider);

    if (!mapEnabled) {
      return TrackingMapPlaceholder(key: widget.placeholderKey);
    }

    return SizedBox(
      height: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GoogleMap(
          key: widget.mapKey,
          initialCameraPosition: widget.mapData.initialCameraPosition,
          myLocationEnabled: widget.showUserLocation,
          myLocationButtonEnabled: widget.showUserLocation,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          polylines: widget.mapData.polylines,
          onMapCreated: (controller) {
            _mapController = controller;
            if (widget.followLatestPosition) {
              _moveCameraToLatest(widget.mapData.latestPosition);
            }
          },
        ),
      ),
    );
  }

  void _moveCameraToLatest(LatLng? latestPosition) {
    final controller = _mapController;
    if (latestPosition == null ||
        controller == null ||
        _samePosition(_lastCameraTarget, latestPosition)) {
      return;
    }

    _lastCameraTarget = latestPosition;
    unawaited(
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(latestPosition, activeRouteCameraZoom),
      ),
    );
  }

  bool _samePosition(LatLng? first, LatLng second) {
    return first?.latitude == second.latitude &&
        first?.longitude == second.longitude;
  }
}

class TrackingMapPlaceholder extends StatelessWidget {
  const TrackingMapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 220,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Center(
          child: Text(
            'Anteprima mappa non disponibile',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
