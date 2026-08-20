import 'package:flutter_test/flutter_test.dart';

import 'package:fitquest/src/tracking/domain/distance_calculator.dart';

void main() {
  test('metersBetween calculates distance from GPS coordinates', () {
    final distance = DistanceCalculator.metersBetween(
      startLatitude: 43.6158,
      startLongitude: 13.5189,
      endLatitude: 43.6160,
      endLongitude: 13.5191,
    );

    expect(distance, closeTo(27.4, 1));
  });

  test('isValidCoordinate rejects invalid latitude and longitude', () {
    expect(DistanceCalculator.isValidCoordinate(43.6158, 13.5189), isTrue);
    expect(DistanceCalculator.isValidCoordinate(91, 13.5189), isFalse);
    expect(DistanceCalculator.isValidCoordinate(43.6158, -181), isFalse);
    expect(DistanceCalculator.isValidCoordinate(double.nan, 13.5189), isFalse);
  });
}
