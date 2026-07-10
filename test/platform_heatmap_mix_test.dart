import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_entity.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_status.dart';
import 'package:driveflow/features/integrations/domain/services/platform_heatmap_builder.dart';
import 'package:driveflow/features/integrations/domain/services/platform_mix_simulator.dart';
import 'package:driveflow/features/integrations/domain/services/platform_net_profit_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final trips = [
    PlatformTripEntity(
      id: '1',
      userId: 'u',
      platform: RidePlatform.uber,
      externalId: 'a',
      fareAmount: 40,
      tipAmount: 0,
      platformFee: 10,
      driverPayout: 30,
      startedAt: DateTime(2026, 7, 8, 19),
      status: PlatformTripStatus.completed,
      distanceKm: 8,
      durationMinutes: 20,
    ),
    PlatformTripEntity(
      id: '2',
      userId: 'u',
      platform: RidePlatform.ninetyNine,
      externalId: 'b',
      fareAmount: 50,
      tipAmount: 5,
      platformFee: 12,
      driverPayout: 43,
      startedAt: DateTime(2026, 7, 9, 20),
      status: PlatformTripStatus.completed,
      distanceKm: 10,
      durationMinutes: 25,
    ),
  ];

  test('heatmap ranks slots by revenue per hour', () {
    final slots = PlatformHeatmapBuilder.build(
      trips: trips,
      now: DateTime(2026, 7, 10),
    );
    expect(slots, isNotEmpty);
    expect(slots.first.revenuePerHour, greaterThan(0));
  });

  test('mix simulator normalizes percentages and uses real duration', () {
    final net = PlatformNetProfitCalculator.fromTrips(
      trips: trips,
      fuelCostPerKm: 0.3,
    );
    expect(net.every((s) => s.workedHours > 0), isTrue);
    final sim = PlatformMixSimulator.simulate(
      mixPercent: {
        RidePlatform.uber: 50,
        RidePlatform.ninetyNine: 50,
        RidePlatform.inDrive: 0,
      },
      netSlices: net,
    );
    expect(sim.projectedMonthlyProfit, greaterThan(0));
    expect(sim.mixPercent.values.fold<double>(0, (s, v) => s + v), closeTo(100, 0.1));
  });
}
