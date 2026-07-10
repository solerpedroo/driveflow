import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_entity.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_status.dart';
import 'package:driveflow/features/integrations/domain/services/earnings_rollup_service.dart';
import 'package:driveflow/features/integrations/domain/entities/earning_source.dart';

void main() {
  group('EarningsRollupService', () {
    test('agrega corridas do mesmo dia em um ganho diário', () {
      final trips = [
        PlatformTripEntity(
          id: '1',
          userId: 'u1',
          platform: RidePlatform.uber,
          externalId: 't1',
          fareAmount: 20,
          tipAmount: 2,
          platformFee: 5,
          driverPayout: 17,
          durationMinutes: 30,
          startedAt: DateTime(2026, 7, 10, 20),
          status: PlatformTripStatus.completed,
        ),
        PlatformTripEntity(
          id: '2',
          userId: 'u1',
          platform: RidePlatform.uber,
          externalId: 't2',
          fareAmount: 15,
          tipAmount: 0,
          platformFee: 4,
          driverPayout: 11,
          durationMinutes: 20,
          startedAt: DateTime(2026, 7, 10, 22),
          status: PlatformTripStatus.completed,
        ),
      ];

      final drafts = EarningsRollupService.rollupDaily(trips: trips);

      expect(drafts, hasLength(1));
      expect(drafts.first.amount, 28);
      expect(drafts.first.rides, 2);
      expect(drafts.first.source, EarningSource.apiSync);
      expect(drafts.first.externalId, contains('rollup:uber:'));
    });

    test('ignora corridas canceladas', () {
      final trips = [
        PlatformTripEntity(
          id: '1',
          userId: 'u1',
          platform: RidePlatform.ninetyNine,
          externalId: 't1',
          fareAmount: 20,
          tipAmount: 0,
          platformFee: 5,
          driverPayout: 15,
          startedAt: DateTime(2026, 7, 10, 18),
          status: PlatformTripStatus.cancelled,
        ),
      ];

      expect(EarningsRollupService.rollupDaily(trips: trips), isEmpty);
    });
  });
}
