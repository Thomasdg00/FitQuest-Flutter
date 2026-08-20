import 'package:geolocator/geolocator.dart';

import '../domain/location_fix.dart';
import '../domain/location_tracker.dart';

class GeolocatorLocationTracker implements LocationTracker {
  const GeolocatorLocationTracker();

  @override
  Future<LocationTrackingAvailability> checkAvailability() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationTrackingAvailability.serviceDisabled;
    }

    final permission = await Geolocator.checkPermission();
    return _mapPermission(permission);
  }

  @override
  Future<LocationTrackingAvailability> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationTrackingAvailability.serviceDisabled;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return _mapPermission(permission);
  }

  @override
  Stream<LocationFix> get positionStream {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).map(_toLocationFix);
  }

  static LocationTrackingAvailability _mapPermission(
    LocationPermission permission,
  ) {
    return switch (permission) {
      LocationPermission.always ||
      LocationPermission.whileInUse => LocationTrackingAvailability.available,
      LocationPermission.denied =>
        LocationTrackingAvailability.permissionDenied,
      LocationPermission.deniedForever =>
        LocationTrackingAvailability.permissionDeniedForever,
      LocationPermission.unableToDetermine =>
        LocationTrackingAvailability.permissionDenied,
    };
  }

  static LocationFix _toLocationFix(Position position) {
    return LocationFix(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: position.timestamp.toUtc(),
    );
  }
}
