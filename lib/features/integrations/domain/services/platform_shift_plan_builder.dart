import '../../../../core/constants/ride_platforms.dart';
import '../entities/platform_heatmap_slot.dart';
import '../entities/platform_shift_plan.dart';

/// Monta plano de turno a partir do heatmap.
abstract final class PlatformShiftPlanBuilder {
  static const planHours = 6;

  static PlatformShiftPlan build({
    required List<PlatformHeatmapSlot> slots,
    required int currentWeekday,
    required int currentHour,
  }) {
    if (slots.isEmpty) return const PlatformShiftPlan(
      blocks: [],
      totalHours: 0,
      projectedRevenue: 0,
    );

    final blocks = <PlatformShiftPlanBlock>[];
    var projected = 0.0;

    for (var h = 0; h < planHours; h++) {
      final hour = (currentHour + h) % 24;
      final weekday = currentWeekday + ((currentHour + h) ~/ 24);
      final normalizedWeekday = ((weekday - 1) % 7) + 1;

      final candidates = slots
          .where((s) => s.weekday == normalizedWeekday && s.hour == hour)
          .toList()
        ..sort((a, b) => b.revenuePerHour.compareTo(a.revenuePerHour));

      if (candidates.isEmpty) continue;

      final best = candidates.first;
      projected += best.revenuePerHour;

      if (blocks.isNotEmpty && blocks.last.platform == best.platform) {
        final last = blocks.last;
        final nextEnd = hour + 1;
        blocks[blocks.length - 1] = PlatformShiftPlanBlock(
          startHour: last.startHour,
          endHour: nextEnd > 23 ? 24 : nextEnd,
          platform: last.platform,
          reason: last.reason,
          expectedRevenuePerHour: last.expectedRevenuePerHour,
        );
      } else {
        blocks.add(
          PlatformShiftPlanBlock(
            startHour: hour,
            endHour: hour + 1,
            platform: best.platform,
            reason: 'Média R\$ ${best.revenuePerHour.toStringAsFixed(0)}/h '
                '(${best.tripCount} corridas)',
            expectedRevenuePerHour: best.revenuePerHour,
          ),
        );
      }
    }

    return PlatformShiftPlan(
      blocks: blocks,
      totalHours: planHours,
      projectedRevenue: projected,
    );
  }

  /// Plano padrão quando não há heatmap — usa melhor plataforma global.
  static PlatformShiftPlan fallback({
    required RidePlatform platform,
    required double revenuePerHour,
    required int currentHour,
  }) {
    return PlatformShiftPlan(
      blocks: [
        PlatformShiftPlanBlock(
          startHour: currentHour,
          endHour: currentHour + planHours,
          platform: platform,
          reason: 'Melhor histórico R\$ ${revenuePerHour.toStringAsFixed(0)}/h',
          expectedRevenuePerHour: revenuePerHour,
        ),
      ],
      totalHours: planHours,
      projectedRevenue: revenuePerHour * planHours,
    );
  }
}
