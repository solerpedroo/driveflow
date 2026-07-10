import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_entity.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_status.dart';
import 'package:driveflow/features/integrations/domain/services/platform_net_profit_calculator.dart';
import 'package:driveflow/features/integrations/domain/services/platform_revenue_trend_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final trip = PlatformTripEntity(
    id: '1',
    userId: 'u',
    platform: RidePlatform.uber,
    externalId: 'ext',
    fareAmount: 30,
    tipAmount: 5,
    platformFee: 8,
    driverPayout: 27,
    startedAt: DateTime(2026, 7, 10, 18),
    endedAt: DateTime(2026, 7, 10, 18, 30),
    status: PlatformTripStatus.completed,
    distanceKm: 10,
    durationMinutes: 30,
  );

  test('net profit subtracts fuel cost', () {
    final slices = PlatformNetProfitCalculator.fromTrips(
      trips: [trip],
      fuelCostPerKm: 0.5,
    );
    expect(slices.single.netAmount, 22);
    expect(slices.single.fuelCost, 5);
  });

  test('trend builds daily points', () {
    final points = PlatformRevenueTrendCalculator.fromTrips(
      trips: [trip],
      days: 7,
      anchor: DateTime(2026, 7, 10),
    );
    expect(points.length, 7);
    expect(points.last.total, 27);
  });
}
