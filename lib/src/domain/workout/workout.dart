class Workout {
  const Workout({
    required this.id,
    required this.startedAt,
    required this.duration,
    required this.distanceMeters,
  });

  final int? id;
  final DateTime startedAt;
  final Duration duration;
  final double distanceMeters;
}
