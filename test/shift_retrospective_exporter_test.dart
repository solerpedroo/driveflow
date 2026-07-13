import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/shift/domain/entities/shift_history_entry.dart';
import 'package:driveflow/features/shift/domain/entities/shift_retrospective.dart';
import 'package:driveflow/features/shift/domain/entities/shift_session_plan_block.dart';
import 'package:driveflow/features/shift/domain/services/shift_retrospective_exporter.dart';

void main() {
  test('buildPdf returns non-empty bytes for retrospective', () async {
    final retrospective = ShiftRetrospective(
      entry: ShiftHistoryEntry(
        id: 's1',
        userId: 'u1',
        startedAt: DateTime(2026, 7, 13, 18),
        endedAt: DateTime(2026, 7, 13, 22),
        elapsed: const Duration(hours: 4),
        accumulatedPause: Duration.zero,
        isTaxiMode: false,
        revenue: 200,
        rides: 5,
        revenuePerHour: 50,
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
        revenueByPlatform: const {RidePlatform.uber: 200},
        expenses: 40,
        netCash: 160,
        expensesByCategory: const {ExpenseCategory.fuel: 40},
      ),
      platformBreakdown: const [
        ShiftPlatformSlice(
          platform: RidePlatform.uber,
          revenue: 200,
          share: 1,
        ),
      ],
      blockOutcomes: const [],
      insight: 'Excelente aderência ao plano.',
    );

    final bytes = await ShiftRetrospectiveExporter.buildPdfBytes(retrospective);

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
