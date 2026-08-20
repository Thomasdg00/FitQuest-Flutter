import 'location_fix.dart';

enum LocationTrackingAvailability {
  available,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unavailable,
}

abstract class LocationTracker {
  Future<LocationTrackingAvailability> checkAvailability();

  Future<LocationTrackingAvailability> requestPermission();

  Stream<LocationFix> get positionStream;
}
