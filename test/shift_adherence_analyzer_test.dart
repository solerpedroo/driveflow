import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/earnings/domain/entities/earning_entity.dart';
import 'package:driveflow/features/shift/domain/entities/shift_session_entity.dart';
import 'package:driveflow/features/shift/domain/entities/shift_session_plan_block.dart';
import 'package:driveflow/features/shift/domain/entities/shift_session_status.dart';
import 'package:driveflow/features/shift/domain/services/shift_adherence_analyzer.dart';

void main() {
  test('scores adherence when dominant platform matches plan block', () {
    final session = ShiftSessionEntity(
      id: 's1',
      startedAt: DateTime(2026, 7, 13, 18),
      endedAt: DateTime(2026, 7, 13, 22),
      status: ShiftSessionStatus.completed,
      isTaxiMode: false,
      planBlocks: const [
        ShiftSessionPlanBlock(
          startHour: 18,
          endHour: 20,
          platform: RidePlatform.uber,
          reason: 'Pico',
          expectedRevenuePerHour: 40,
        ),
        ShiftSessionPlanBlock(
          startHour: 20,
          endHour: 22,
          platform: RidePlatform.ninetyNine,
          reason: 'Noite',
          expectedRevenuePerHour: 50,
        ),
      ],
    );

    final earnings = [
      EarningEntity(
        id: 'e1',
        userId: 'u1',
        platform: RidePlatform.uber,
        amount: 80,
        rides: 2,
        workedHours: 1,
        date: DateTime(2026, 7, 13, 19),
        createdAt: DateTime(2026, 7, 13, 19),
      ),
      EarningEntity(
        id: 'e2',
        userId: 'u1',
        platform: RidePlatform.ninetyNine,
        amount: 90,
        rides: 2,
        workedHours: 1,
        date: DateTime(2026, 7, 13, 21),
        createdAt: DateTime(2026, 7, 13, 21),
      ),
    ];

    final result = ShiftAdherenceAnalyzer.analyze(
      session: session,
      earnings: earnings,
    );

    expect(result.score, 100);
    expect(result.matchedBlocks, 2);
    expect(result.totalBlocks, 2);
  });
}
