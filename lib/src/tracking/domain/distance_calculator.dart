import 'dart:math' as math;

class DistanceCalculator {
  const DistanceCalculator._();

  static const double _earthRadiusMeters = 6371000;

  static bool isValidCoordinate(double latitude, double longitude) {
    return latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  static double metersBetween({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    if (!isValidCoordinate(startLatitude, startLongitude) ||
        !isValidCoordinate(endLatitude, endLongitude)) {
      return 0;
    }

    final startLatitudeRadians = _toRadians(startLatitude);
    final endLatitudeRadians = _toRadians(endLatitude);
    final latitudeDelta = _toRadians(endLatitude - startLatitude);
    final longitudeDelta = _toRadians(endLongitude - startLongitude);

    final haversine =
        math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
        math.cos(startLatitudeRadians) *
            math.cos(endLatitudeRadians) *
            math.sin(longitudeDelta / 2) *
            math.sin(longitudeDelta / 2);

    final centralAngle =
        2 * math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));

    return _earthRadiusMeters * centralAngle;
  }

  static double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
