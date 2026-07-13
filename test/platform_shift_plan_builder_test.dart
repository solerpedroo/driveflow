import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_heatmap_slot.dart';
import 'package:driveflow/features/integrations/domain/services/platform_shift_plan_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shift plan merges consecutive hours for same platform', () {
    final slots = [
      PlatformHeatmapSlot(
        weekday: DateTime.monday,
        hour: 18,
        platform: RidePlatform.ninetyNine,
        revenuePerHour: 45,
        tripCount: 8,
        totalRevenue: 360,
      ),
      PlatformHeatmapSlot(
        weekday: DateTime.monday,
        hour: 19,
        platform: RidePlatform.ninetyNine,
        revenuePerHour: 42,
        tripCount: 6,
        totalRevenue: 252,
      ),
    ];

    final plan = PlatformShiftPlanBuilder.build(
      slots: slots,
      currentWeekday: DateTime.monday,
      currentHour: 18,
    );

    expect(plan.blocks, isNotEmpty);
    expect(plan.blocks.first.platform, RidePlatform.ninetyNine);
    expect(plan.projectedRevenue, greaterThan(0));
  });
}
