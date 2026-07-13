import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_heatmap_slot.dart';
import 'package:driveflow/features/shift/domain/entities/shift_block_outcome.dart';
import 'package:driveflow/features/shift/domain/entities/shift_history_entry.dart';
import 'package:driveflow/features/shift/domain/entities/shift_session_plan_block.dart';
import 'package:driveflow/features/shift/domain/services/shift_plan_advisor.dart';

void main() {
  test('adjusts heatmap plan when history favors another platform', () {
    const block = ShiftSessionPlanBlock(
      startHour: 18,
      endHour: 20,
      platform: RidePlatform.uber,
      reason: 'Heatmap',
      expectedRevenuePerHour: 40,
    );

    final history = List.generate(2, (index) {
      return ShiftHistoryEntry(
        id: 's$index',
        userId: 'u1',
        startedAt: DateTime(2026, 7, 10 + index, 18),
        endedAt: DateTime(2026, 7, 10 + index, 20),
        elapsed: const Duration(hours: 2),
        accumulatedPause: Duration.zero,
        isTaxiMode: false,
        revenue: 100,
        rides: 2,
        adherenceScore: 0,
        matchedPlanBlocks: 0,
        totalPlanBlocks: 1,
        planBlocks: const [block],
        revenueByPlatform: const {RidePlatform.ninetyNine: 100},
        blockOutcomes: [
          ShiftBlockOutcome(
            block: block,
            actualPlatform: RidePlatform.ninetyNine,
            matched: false,
            revenue: 100,
          ),
        ],
      );
    });

    final slots = [
      PlatformHeatmapSlot(
        weekday: DateTime.monday,
        hour: 18,
        platform: RidePlatform.uber,
        revenuePerHour: 45,
        tripCount: 8,
        totalRevenue: 360,
      ),
      PlatformHeatmapSlot(
        weekday: DateTime.monday,
        hour: 19,
        platform: RidePlatform.uber,
        revenuePerHour: 42,
        tripCount: 6,
        totalRevenue: 252,
      ),
    ];

    final plan = ShiftPlanAdvisor.build(
      heatmapSlots: slots,
      history: history,
      currentWeekday: DateTime.monday,
      currentHour: 18,
    );

    expect(plan.blocks, isNotEmpty);
    expect(plan.blocks.first.platform, RidePlatform.ninetyNine);
    expect(plan.blocks.first.reason, contains('Histórico'));
  });
}
