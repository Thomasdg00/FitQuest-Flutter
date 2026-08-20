enum TrackingSaveStatus { saved, notSaved, failed }

class TrackingSaveResult {
  const TrackingSaveResult._({
    required this.status,
    this.workoutId,
    this.routePointCount = 0,
    this.message,
  });

  factory TrackingSaveResult.saved({
    required int workoutId,
    required int routePointCount,
  }) {
    return TrackingSaveResult._(
      status: TrackingSaveStatus.saved,
      workoutId: workoutId,
      routePointCount: routePointCount,
    );
  }

  factory TrackingSaveResult.notSaved(String message) {
    return TrackingSaveResult._(
      status: TrackingSaveStatus.notSaved,
      message: message,
    );
  }

  factory TrackingSaveResult.failed() {
    return const TrackingSaveResult._(
      status: TrackingSaveStatus.failed,
      message: 'Impossibile salvare l\'attività.',
    );
  }

  final TrackingSaveStatus status;
  final int? workoutId;
  final int routePointCount;
  final String? message;
}
