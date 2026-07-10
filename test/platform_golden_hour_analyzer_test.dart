import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_entity.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_status.dart';
import 'package:driveflow/features/integrations/domain/services/platform_golden_hour_analyzer.dart';

void main() {
  test('PlatformGoldenHourAnalyzer encontra melhor slot', () {
    final trips = [
      PlatformTripEntity(
        id: '1',
        userId: 'u1',
        platform: RidePlatform.ninetyNine,
        externalId: 't1',
        fareAmount: 30,
        tipAmount: 0,
        platformFee: 6,
        driverPayout: 24,
        durationMinutes: 30,
        startedAt: DateTime(2026, 7, 10, 19),
        status: PlatformTripStatus.completed,
      ),
    ];

    final slots = PlatformGoldenHourAnalyzer.analyze(trips);
    expect(slots, isNotEmpty);
    expect(slots.first.platform, RidePlatform.ninetyNine);
  });

  test('sem durationMinutes não infla R$/h com 1h fictícia', () {
    final trips = [
      PlatformTripEntity(
        id: '1',
        userId: 'u1',
        platform: RidePlatform.uber,
        externalId: 't1',
        fareAmount: 30,
        tipAmount: 0,
        platformFee: 6,
        driverPayout: 24,
        startedAt: DateTime(2026, 7, 10, 19),
        status: PlatformTripStatus.completed,
      ),
    ];

    final slots = PlatformGoldenHourAnalyzer.analyze(trips);
    expect(slots, isEmpty);
  });
}
