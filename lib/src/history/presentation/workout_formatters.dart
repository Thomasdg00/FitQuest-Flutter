String formatWorkoutDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  return '${_twoDigits(local.day)}/${_twoDigits(local.month)}/'
      '${_fourDigits(local.year)} ${_twoDigits(local.hour)}:'
      '${_twoDigits(local.minute)}';
}

String formatWorkoutTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  return '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
}

String formatWorkoutDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return '$hours h ${_twoDigits(minutes)} min';
  }
  if (minutes > 0) {
    return '$minutes min ${_twoDigits(seconds)} s';
  }
  return '$seconds s';
}

String formatWorkoutDistance(double meters) {
  if (meters >= 1000) {
    return '${_formatDecimal(meters / 1000)} km';
  }
  return '${meters.round()} m';
}

String formatCoordinate(double value) {
  return value.toStringAsFixed(5);
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String _fourDigits(int value) => value.toString().padLeft(4, '0');

String _formatDecimal(double value) {
  return value.toStringAsFixed(2).replaceAll('.', ',');
}
