import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_entity.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_status.dart';
import 'package:driveflow/features/integrations/domain/services/platform_efficiency_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('efficiency analyzer computes per ride and per km', () {
    final trips = [
      PlatformTripEntity(
        id: '1',
        userId: 'u',
        platform: RidePlatform.uber,
        externalId: 'a',
        fareAmount: 30,
        tipAmount: 5,
        platformFee: 8,
        driverPayout: 27,
        startedAt: DateTime(2026, 7, 5, 14),
        endedAt: DateTime(2026, 7, 5, 14, 20),
        status: PlatformTripStatus.completed,
        distanceKm: 10,
      ),
    ];

    final snapshots = PlatformEfficiencyAnalyzer.analyze(trips: trips);
    expect(snapshots.single.avgPerRide, 27);
    expect(snapshots.single.avgPerKm, closeTo(2.7, 0.01));
    expect(snapshots.single.avgTipPerRide, 5);
  });
}
