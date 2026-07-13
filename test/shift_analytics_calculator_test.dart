import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/shift/domain/entities/shift_analytics_period.dart';
import 'package:driveflow/features/shift/domain/entities/shift_history_entry.dart';
import 'package:driveflow/features/shift/domain/services/shift_analytics_calculator.dart';

void main() {
  test('aggregates revenue, adherence and daily points for period', () {
    final anchor = DateTime(2026, 7, 13, 20);
    final history = [
      ShiftHistoryEntry(
        id: 's1',
        userId: 'u1',
        startedAt: DateTime(2026, 7, 13, 18),
        endedAt: DateTime(2026, 7, 13, 22),
        elapsed: const Duration(hours: 4),
        accumulatedPause: Duration.zero,
        isTaxiMode: false,
        revenue: 200,
        rides: 4,
        revenuePerHour: 50,
        adherenceScore: 80,
        matchedPlanBlocks: 2,
        totalPlanBlocks: 2,
        planBlocks: const [],
        revenueByPlatform: const {RidePlatform.uber: 200},
      ),
      ShiftHistoryEntry(
        id: 's2',
        userId: 'u1',
        startedAt: DateTime(2026, 7, 12, 19),
        endedAt: DateTime(2026, 7, 12, 23),
        elapsed: const Duration(hours: 4),
        accumulatedPause: Duration.zero,
        isTaxiMode: false,
        revenue: 100,
        rides: 2,
        revenuePerHour: 25,
        adherenceScore: 60,
        matchedPlanBlocks: 1,
        totalPlanBlocks: 2,
        planBlocks: const [],
        revenueByPlatform: const {RidePlatform.ninetyNine: 100},
      ),
      ShiftHistoryEntry(
        id: 's0',
        userId: 'u1',
        startedAt: DateTime(2026, 7, 1, 18),
        endedAt: DateTime(2026, 7, 1, 22),
        elapsed: const Duration(hours: 4),
        accumulatedPause: Duration.zero,
        isTaxiMode: false,
        revenue: 50,
        rides: 1,
        revenuePerHour: 12.5,
        adherenceScore: 40,
        matchedPlanBlocks: 0,
        totalPlanBlocks: 1,
        planBlocks: const [],
        revenueByPlatform: const {RidePlatform.uber: 50},
      ),
    ];

    final summary = ShiftAnalyticsCalculator.calculate(
      history: history,
      period: ShiftAnalyticsPeriod.days7,
      anchor: anchor,
    );

    expect(summary.shiftCount, 2);
    expect(summary.totalRevenue, 300);
    expect(summary.totalRides, 6);
    expect(summary.avgAdherence, closeTo(70, 0.1));
    expect(summary.dailyPoints, hasLength(7));
    expect(summary.platformRevenue[RidePlatform.uber], 200);
    expect(summary.platformRevenue[RidePlatform.ninetyNine], 100);
    expect(summary.comparison, isNotNull);
    expect(summary.comparison!.currentRevenue, 300);
    expect(summary.comparison!.previousRevenue, 50);
    expect(summary.bestRevenueShift?.id, 's1');
  });

  test('returns empty summary when no shifts in window', () {
    final summary = ShiftAnalyticsCalculator.calculate(
      history: const [],
      period: ShiftAnalyticsPeriod.days30,
    );

    expect(summary.isEmpty, isTrue);
    expect(summary.dailyPoints, isEmpty);
  });
}
