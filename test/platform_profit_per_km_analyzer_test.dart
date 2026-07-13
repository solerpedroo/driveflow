import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_entity.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_status.dart';
import 'package:driveflow/features/integrations/domain/services/platform_profit_per_km_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('profit per km subtracts fuel cost', () {
    final trips = [
      PlatformTripEntity(
        id: '1',
        userId: 'u',
        platform: RidePlatform.uber,
        externalId: 'a',
        fareAmount: 30,
        tipAmount: 0,
        platformFee: 8,
        driverPayout: 22,
        startedAt: DateTime(2026, 7, 5, 14),
        endedAt: DateTime(2026, 7, 5, 14, 20),
        status: PlatformTripStatus.completed,
        distanceKm: 10,
      ),
    ];

    final snapshots = PlatformProfitPerKmAnalyzer.analyze(
      trips: trips,
      fuelCostPerKm: 0.5,
    );

    expect(snapshots.single.netProfit, 17);
    expect(snapshots.single.profitPerKm, closeTo(1.7, 0.01));
  });
}
