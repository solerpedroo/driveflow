import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_shift_recommendation.dart';
import 'package:driveflow/features/shift/domain/entities/shift_session_entity.dart';
import 'package:driveflow/features/shift/domain/entities/shift_session_plan_block.dart';
import 'package:driveflow/features/shift/domain/entities/shift_session_status.dart';
import 'package:driveflow/features/shift/domain/services/shift_plan_tracker.dart';

void main() {
  final session = ShiftSessionEntity(
    id: 's1',
    startedAt: DateTime(2026, 7, 13, 18),
    status: ShiftSessionStatus.active,
    isTaxiMode: false,
    planBlocks: const [
      ShiftSessionPlanBlock(
        startHour: 18,
        endHour: 20,
        platform: RidePlatform.uber,
        reason: r'Melhor R$/h',
        expectedRevenuePerHour: 45,
      ),
      ShiftSessionPlanBlock(
        startHour: 20,
        endHour: 22,
        platform: RidePlatform.ninetyNine,
        reason: 'Pico noturno',
        expectedRevenuePerHour: 52,
      ),
    ],
  );

  test('currentBlock resolves by hour', () {
    final block = ShiftPlanTracker.currentBlock(
      session: session,
      now: DateTime(2026, 7, 13, 19),
    );

    expect(block?.platform, RidePlatform.uber);
  });

  test('evaluate detects switch when recommendation differs', () {
    final adherence = ShiftPlanTracker.evaluate(
      session: session,
      now: DateTime(2026, 7, 13, 19),
      recommendation: PlatformShiftRecommendation(
        recommended: RidePlatform.ninetyNine,
        reason: 'Melhor agora',
        confidence: 0.8,
        alternatives: const [],
        bestHourSlot: 'Noite',
      ),
    );

    expect(adherence.shouldSwitch, isTrue);
    expect(adherence.recommendedPlatform, RidePlatform.ninetyNine);
  });
}
