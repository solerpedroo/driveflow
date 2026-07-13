import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/shift/domain/entities/shift_block_outcome.dart';
import 'package:driveflow/features/shift/domain/entities/shift_history_entry.dart';
import 'package:driveflow/features/shift/domain/entities/shift_session_plan_block.dart';
import 'package:driveflow/features/shift/domain/services/shift_coach_analyzer.dart';

void main() {
  test('detects low adherence and typical deviation hour', () {
    final block = const ShiftSessionPlanBlock(
      startHour: 20,
      endHour: 22,
      platform: RidePlatform.uber,
      reason: 'Pico',
      expectedRevenuePerHour: 40,
    );

    final history = List.generate(3, (index) {
      return ShiftHistoryEntry(
        id: 's$index',
        userId: 'u1',
        startedAt: DateTime(2026, 7, 10 + index, 18),
        endedAt: DateTime(2026, 7, 10 + index, 22),
        elapsed: const Duration(hours: 4),
        accumulatedPause: Duration.zero,
        isTaxiMode: false,
        revenue: 150,
        rides: 3,
        adherenceScore: 40,
        matchedPlanBlocks: 0,
        totalPlanBlocks: 1,
        planBlocks: const [block],
        revenueByPlatform: const {RidePlatform.ninetyNine: 150},
        blockOutcomes: [
          ShiftBlockOutcome(
            block: block,
            actualPlatform: RidePlatform.ninetyNine,
            matched: false,
            revenue: 150,
          ),
        ],
      );
    });

    final insight = ShiftCoachAnalyzer.analyze(history: history);

    expect(insight, isNotNull);
    expect(insight!.shiftsAnalyzed, 3);
    expect(insight.avgAdherence, closeTo(40, 0.1));
    expect(insight.typicalDeviationHour, 20);
    expect(insight.typicalDeviationPlatform, RidePlatform.ninetyNine);
    expect(insight.tips, isNotEmpty);
  });

  test('retrospective insight suggests adaptive plan on low adherence', () {
    final entry = ShiftHistoryEntry(
      id: 's1',
      userId: 'u1',
      startedAt: DateTime(2026, 7, 13, 18),
      endedAt: DateTime(2026, 7, 13, 22),
      elapsed: const Duration(hours: 4),
      accumulatedPause: Duration.zero,
      isTaxiMode: false,
      revenue: 120,
      rides: 3,
      adherenceScore: 30,
      matchedPlanBlocks: 0,
      totalPlanBlocks: 1,
      planBlocks: const [
        ShiftSessionPlanBlock(
          startHour: 18,
          endHour: 22,
          platform: RidePlatform.uber,
          reason: 'Pico',
          expectedRevenuePerHour: 40,
        ),
      ],
      revenueByPlatform: const {RidePlatform.uber: 120},
    );

    final message = ShiftCoachAnalyzer.retrospectiveInsight(entry: entry);

    expect(message, contains('plano adaptativo'));
  });
}
