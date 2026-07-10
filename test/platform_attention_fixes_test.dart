import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/integrations/domain/entities/integration_status.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_connection_entity.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_entity.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_status.dart';
import 'package:driveflow/features/integrations/domain/services/platform_mix_simulator.dart';
import 'package:driveflow/features/integrations/domain/services/platform_net_profit_calculator.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_payout_policy.dart';
import 'package:driveflow/features/integrations/domain/services/platform_payout_rules.dart';
import 'package:driveflow/features/integrations/domain/services/platform_region_label.dart';
import 'package:driveflow/features/integrations/domain/services/platform_trip_duration.dart';

void main() {
  test('workedHours usa durationMinutes real', () {
    final trip = PlatformTripEntity(
      id: '1',
      userId: 'u',
      platform: RidePlatform.uber,
      externalId: 'a',
      fareAmount: 30,
      tipAmount: 0,
      platformFee: 8,
      driverPayout: 22,
      startedAt: DateTime(2026, 7, 10),
      status: PlatformTripStatus.completed,
      durationMinutes: 30,
    );
    expect(PlatformTripDuration.workedHours(trip), 0.5);
  });

  test('mix simulator usa workedHours do slice', () {
    final trip = PlatformTripEntity(
      id: '1',
      userId: 'u',
      platform: RidePlatform.uber,
      externalId: 'a',
      fareAmount: 60,
      tipAmount: 0,
      platformFee: 10,
      driverPayout: 50,
      startedAt: DateTime(2026, 7, 10),
      status: PlatformTripStatus.completed,
      durationMinutes: 60,
      distanceKm: 10,
    );
    final slices = PlatformNetProfitCalculator.fromTrips(
      trips: [trip],
      fuelCostPerKm: 0,
    );
    expect(slices.single.workedHours, 1);

    final sim = PlatformMixSimulator.simulate(
      mixPercent: {RidePlatform.uber: 100},
      netSlices: slices,
      workingDaysPerMonth: 1,
      hoursPerDay: 1,
    );
    expect(sim.projectedMonthlyProfit, closeTo(50, 0.01));
  });

  test('payout policy lê metadata da conexão', () {
    final overrides = PlatformPayoutRules.overridesFromConnections([
      const PlatformConnectionEntity(
        id: 'c1',
        userId: 'u',
        platform: RidePlatform.uber,
        status: IntegrationStatus.connected,
        metadata: {'settlement_days': 4},
      ),
    ]);
    final policy = PlatformPayoutRules.resolve(
      RidePlatform.uber,
      partnerOverrides: overrides,
    );
    expect(policy.settlementDays, 4);
    expect(policy.source, PayoutPolicySource.partnerApi);
  });

  test('region label usa dropoff e distância como fallback', () {
    final withDropoff = PlatformTripEntity(
      id: '1',
      userId: 'u',
      platform: RidePlatform.uber,
      externalId: 'a',
      fareAmount: 20,
      tipAmount: 0,
      platformFee: 5,
      driverPayout: 15,
      startedAt: DateTime(2026, 7, 10),
      status: PlatformTripStatus.completed,
      dropoffLabel: 'Pinheiros, São Paulo',
    );
    expect(
      PlatformRegionLabel.fromTrip(withDropoff),
      'Pinheiros',
    );

    final shortTrip = PlatformTripEntity(
      id: '2',
      userId: 'u',
      platform: RidePlatform.uber,
      externalId: 'b',
      fareAmount: 15,
      tipAmount: 0,
      platformFee: 4,
      driverPayout: 11,
      startedAt: DateTime(2026, 7, 10),
      status: PlatformTripStatus.completed,
      distanceKm: 3,
    );
    expect(
      PlatformRegionLabel.fromTrip(shortTrip),
      PlatformRegionLabel.shortTripLabel,
    );
  });
}
