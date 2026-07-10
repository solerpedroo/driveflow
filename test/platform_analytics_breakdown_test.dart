import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/earnings/domain/entities/earning_entity.dart';
import 'package:driveflow/features/goals/domain/entities/goal_entity.dart';
import 'package:driveflow/features/integrations/domain/entities/earning_source.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_entity.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_status.dart';
import 'package:driveflow/features/integrations/domain/services/platform_analytics_breakdown.dart';
import 'package:driveflow/features/integrations/domain/services/platform_goal_progress_calculator.dart';
import 'package:driveflow/features/integrations/domain/services/platform_revenue_trend_calculator.dart';

void main() {
  final today = DateTime(2026, 7, 10, 18);

  final trip = PlatformTripEntity(
    id: '1',
    userId: 'u',
    platform: RidePlatform.uber,
    externalId: 'ext',
    fareAmount: 30,
    tipAmount: 0,
    platformFee: 8,
    driverPayout: 27,
    startedAt: today,
    status: PlatformTripStatus.completed,
  );

  test('fromTrips agrupa payout por app', () {
    final slices = PlatformAnalyticsBreakdown.fromTrips([trip]);
    expect(slices.single.amount, 27);
    expect(slices.single.rides, 1);
  });

  test('todayMix prioriza trips sobre earnings duplicados', () {
    final slices = PlatformAnalyticsBreakdown.todayMix(
      earnings: [
        EarningEntity(
          id: 'e1',
          userId: 'u',
          platform: RidePlatform.uber,
          amount: 27,
          rides: 1,
          workedHours: 1,
          date: today,
          source: EarningSource.apiSync,
        ),
      ],
      trips: [trip],
      anchor: today,
    );
    expect(slices.single.amount, 27);
  });

  test('fromTripsOrEarnings prioriza trips', () {
    final slices = PlatformAnalyticsBreakdown.fromTripsOrEarnings(
      trips: [trip],
      earnings: [
        EarningEntity(
          id: 'e1',
          userId: 'u',
          platform: RidePlatform.uber,
          amount: 99,
          rides: 9,
          workedHours: 1,
          date: today,
        ),
      ],
    );
    expect(slices.single.amount, 27);
    expect(slices.single.rides, 1);
  });

  test('goal progress não duplica trip + earning rollup', () {
    final progress = PlatformGoalProgressCalculator.calculate(
      goals: const GoalEntity(
        id: 'g',
        userId: 'u',
        daily: 300,
        weekly: 0,
        monthly: 0,
        yearly: 0,
      ),
      earnings: [
        EarningEntity(
          id: 'e1',
          userId: 'u',
          platform: RidePlatform.uber,
          amount: 27,
          rides: 1,
          workedHours: 1,
          date: today,
          source: EarningSource.apiSync,
        ),
      ],
      trips: [trip],
      now: today,
    );
    expect(progress.single.actualAmount, 27);
  });

  test('periodDelta compara metades do período', () {
    final points = PlatformRevenueTrendCalculator.fromTrips(
      trips: [trip],
      days: 8,
      anchor: today,
    );
    final deltas = PlatformRevenueTrendCalculator.periodDeltaByPlatform(
      points: points,
    );
    expect(deltas.containsKey(RidePlatform.uber), isTrue);
  });
}
