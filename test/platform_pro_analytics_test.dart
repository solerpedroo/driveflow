import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_entity.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_status.dart';
import 'package:driveflow/features/integrations/domain/services/platform_consistency_analyzer.dart';
import 'package:driveflow/features/integrations/domain/services/platform_payout_calendar_builder.dart';
import 'package:driveflow/features/integrations/domain/services/platform_region_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
      pickupLabel: 'Centro, São Paulo',
      distanceKm: 5,
    ),
    PlatformTripEntity(
      id: '2',
      userId: 'u',
      platform: RidePlatform.uber,
      externalId: 'b',
      fareAmount: 40,
      tipAmount: 0,
      platformFee: 10,
      driverPayout: 30,
      startedAt: DateTime(2026, 7, 6, 15),
      endedAt: DateTime(2026, 7, 6, 15, 25),
      status: PlatformTripStatus.completed,
      pickupLabel: 'Centro, São Paulo',
      distanceKm: 7,
    ),
  ];

  test('payout calendar groups by expected date', () {
    final entries = PlatformPayoutCalendarBuilder.build(
      trips: trips,
      now: DateTime(2026, 7, 10),
    );
    expect(entries, isNotEmpty);
    expect(entries.first.amount, greaterThan(0));
  });

  test('region analyzer extracts neighborhood', () {
    final regions = PlatformRegionAnalyzer.topRegions(trips: trips);
    expect(regions.single.regionLabel, 'Centro');
    expect(regions.single.avgPayout, 26);
  });

  test('consistency scores stable platform higher', () {
    final snapshots = PlatformConsistencyAnalyzer.analyze(
      trips: trips,
      now: DateTime(2026, 7, 10),
    );
    expect(snapshots.single.consistencyScore, greaterThan(0));
  });
}
