import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_shift_plan.dart';
import 'package:driveflow/features/shift/domain/entities/shift_coach_insight.dart';
import 'package:driveflow/features/shift/domain/services/shift_automation_scheduler.dart';

void main() {
  test('plans pre-shift reminder from adaptive plan first block', () {
    final reminder = ShiftAutomationScheduler.plan(
      adaptivePlan: const PlatformShiftPlan(
        blocks: [
          PlatformShiftPlanBlock(
            startHour: 18,
            endHour: 20,
            platform: RidePlatform.uber,
            reason: 'Pico',
            expectedRevenuePerHour: 40,
          ),
        ],
        totalHours: 2,
        projectedRevenue: 80,
      ),
      coaching: null,
      hasActiveShift: false,
    );

    expect(reminder, isNotNull);
    expect(reminder!.targetHour, 18);
    expect(reminder.deepLink, contains('driveflow://shift/start'));
  });

  test('skips reminder when shift is active', () {
    final reminder = ShiftAutomationScheduler.plan(
      adaptivePlan: null,
      coaching: const ShiftCoachInsight(
        shiftsAnalyzed: 3,
        avgAdherence: 70,
        headline: 'Ok',
        detail: 'Detalhe',
        tips: const [],
        typicalDeviationHour: 20,
      ),
      hasActiveShift: true,
    );

    expect(reminder, isNull);
  });
}
