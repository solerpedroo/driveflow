import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_entity.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_status.dart';
import 'package:driveflow/features/integrations/domain/services/platform_fee_analyzer.dart';

void main() {
  group('PlatformFeeAnalyzer', () {
    test('identifica plataforma com menor take rate', () {
      final trips = [
        PlatformTripEntity(
          id: '1',
          userId: 'u1',
          platform: RidePlatform.uber,
          externalId: 'u1',
          fareAmount: 100,
          tipAmount: 0,
          platformFee: 25,
          driverPayout: 75,
          startedAt: DateTime(2026, 7, 10),
          status: PlatformTripStatus.completed,
        ),
        PlatformTripEntity(
          id: '2',
          userId: 'u1',
          platform: RidePlatform.ninetyNine,
          externalId: 'n1',
          fareAmount: 100,
          tipAmount: 0,
          platformFee: 18,
          driverPayout: 82,
          startedAt: DateTime(2026, 7, 10),
          status: PlatformTripStatus.completed,
        ),
      ];

      final snapshots = PlatformFeeAnalyzer.analyze(trips);
      expect(snapshots.first.platform, RidePlatform.ninetyNine);
      expect(snapshots.first.avgTakeRatePercent, 18);
    });
  });
}
