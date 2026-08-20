class WeeklyGoal {
  const WeeklyGoal({
    required this.id,
    required this.weekStartDate,
    required this.targetDistanceMeters,
  });

  final int? id;
  final DateTime weekStartDate;
  final double targetDistanceMeters;
}
