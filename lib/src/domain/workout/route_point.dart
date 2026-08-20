class RoutePoint {
  const RoutePoint({
    required this.id,
    required this.workoutId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  final int? id;
  final int workoutId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
}
