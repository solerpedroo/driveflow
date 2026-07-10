import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_entity.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_status.dart';
import 'package:driveflow/features/integrations/domain/services/platform_score_calculator.dart';

void main() {
  test('PlatformScoreCalculator ranqueia plataformas', () {
    final trips = [
      PlatformTripEntity(
        id: '1',
        userId: 'u1',
        platform: RidePlatform.uber,
        externalId: 'u1',
        fareAmount: 50,
        tipAmount: 0,
        platformFee: 15,
        driverPayout: 35,
        durationMinutes: 60,
        startedAt: DateTime(2026, 7, 10, 10),
        status: PlatformTripStatus.completed,
      ),
      PlatformTripEntity(
        id: '2',
        userId: 'u1',
        platform: RidePlatform.ninetyNine,
        externalId: 'n1',
        fareAmount: 40,
        tipAmount: 0,
        platformFee: 8,
        driverPayout: 32,
        durationMinutes: 60,
        startedAt: DateTime(2026, 7, 10, 11),
        status: PlatformTripStatus.completed,
      ),
    ];

    final scores = PlatformScoreCalculator.calculate(trips);
    expect(scores, isNotEmpty);
    expect(scores.first.score, greaterThan(0));
  });
}
