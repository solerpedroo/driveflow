import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/earnings/domain/entities/earning_entity.dart';
import 'package:driveflow/features/shift/domain/entities/shift_history_entry.dart';
import 'package:driveflow/features/shift/domain/entities/shift_session_plan_block.dart';
import 'package:driveflow/features/shift/domain/services/shift_retrospective_builder.dart';

void main() {
  test('builds insight and block outcomes from history entry', () {
    final entry = ShiftHistoryEntry(
      id: 's1',
      userId: 'u1',
      startedAt: DateTime(2026, 7, 13, 18),
      endedAt: DateTime(2026, 7, 13, 22),
      elapsed: const Duration(hours: 4),
      accumulatedPause: Duration.zero,
      isTaxiMode: false,
      revenue: 170,
      rides: 4,
      revenuePerHour: 42.5,
      adherenceScore: 100,
      matchedPlanBlocks: 1,
      totalPlanBlocks: 1,
      planBlocks: const [
        ShiftSessionPlanBlock(
          startHour: 18,
          endHour: 22,
          platform: RidePlatform.uber,
          reason: 'Melhor slot',
          expectedRevenuePerHour: 40,
        ),
      ],
      revenueByPlatform: const {RidePlatform.uber: 170},
    );

    final retrospective = ShiftRetrospectiveBuilder.build(
      entry: entry,
      earnings: [
        EarningEntity(
          id: 'e1',
          userId: 'u1',
          platform: RidePlatform.uber,
          amount: 170,
          rides: 4,
          workedHours: 4,
          date: DateTime(2026, 7, 13, 20),
          createdAt: DateTime(2026, 7, 13, 20),
        ),
      ],
    );

    expect(retrospective.platformBreakdown, hasLength(1));
    expect(retrospective.blockOutcomes.first.matched, isTrue);
    expect(retrospective.insight, contains('aderência'));
  });
}
