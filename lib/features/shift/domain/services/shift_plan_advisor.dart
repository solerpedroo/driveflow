import '../../../../core/constants/ride_platforms.dart';
import '../../../integrations/domain/entities/platform_heatmap_slot.dart';
import '../../../integrations/domain/entities/platform_shift_plan.dart';
import '../../../integrations/domain/services/platform_shift_plan_builder.dart';
import '../entities/shift_history_entry.dart';
import 'shift_coach_analyzer.dart';

/// Combina heatmap com histórico de turnos para sugerir plano adaptativo.
abstract final class ShiftPlanAdvisor {
  static const minDeviationVotes = 2;

  static PlatformShiftPlan build({
    required List<PlatformHeatmapSlot> heatmapSlots,
    required List<ShiftHistoryEntry> history,
    required int currentWeekday,
    required int currentHour,
    int maxHistory = ShiftCoachAnalyzer.defaultLookback,
  }) {
    final base = PlatformShiftPlanBuilder.build(
      slots: heatmapSlots,
      currentWeekday: currentWeekday,
      currentHour: currentHour,
    );

    if (base.isEmpty || history.isEmpty) return base;

    final recent = history.take(maxHistory).toList(growable: false);
    final hourVotes = _actualPlatformVotesByHour(recent);

    final adjusted = base.blocks.map((block) {
      final override = _overrideForBlock(block.startHour, block.endHour, hourVotes);
      if (override == null || override.platform == block.platform) {
        return block;
      }

      return PlatformShiftPlanBlock(
        startHour: block.startHour,
        endHour: block.endHour,
        platform: override.platform,
        reason: 'Histórico: ${override.platform.label} rendeu mais neste horário '
            '(${override.votes} turnos)',
        expectedRevenuePerHour: block.expectedRevenuePerHour,
      );
    }).toList(growable: false);

    final merged = _mergeConsecutive(adjusted);
    final projected = merged.fold<double>(
      0,
      (sum, block) => sum + block.expectedRevenuePerHour * _blockHours(block),
    );

    return PlatformShiftPlan(
      blocks: merged,
      totalHours: base.totalHours,
      projectedRevenue: projected,
    );
  }

  static Map<int, Map<RidePlatform, int>> _actualPlatformVotesByHour(
    List<ShiftHistoryEntry> history,
  ) {
    final votes = <int, Map<RidePlatform, int>>{};

    void addVote(int hour, RidePlatform platform) {
      final bucket = votes.putIfAbsent(hour, () => {});
      bucket[platform] = (bucket[platform] ?? 0) + 1;
    }

    for (final entry in history) {
      if (entry.blockOutcomes.isNotEmpty) {
        for (final outcome in entry.blockOutcomes) {
          final platform = outcome.actualPlatform;
          if (platform == null) continue;
          for (var h = outcome.block.startHour; h < outcome.block.endHour; h++) {
            addVote(h % 24, platform);
          }
        }
        continue;
      }

      entry.planBlocks.forEach((block) {
        final dominant = entry.revenueByPlatform.entries
            .where((e) => e.value > 0)
            .toList(growable: false);
        if (dominant.isEmpty) return;
        final platform =
            dominant.reduce((a, b) => a.value >= b.value ? a : b).key;
        for (var h = block.startHour; h < block.endHour; h++) {
          addVote(h % 24, platform);
        }
      });
    }

    return votes;
  }

  static ({RidePlatform platform, int votes})? _overrideForBlock(
    int startHour,
    int endHour,
    Map<int, Map<RidePlatform, int>> hourVotes,
  ) {
    final totals = <RidePlatform, int>{};
    for (var hour = startHour; hour < endHour; hour++) {
      final bucket = hourVotes[hour % 24];
      if (bucket == null) continue;
      bucket.forEach((platform, count) {
        totals[platform] = (totals[platform] ?? 0) + count;
      });
    }

    if (totals.isEmpty) return null;

    final best = totals.entries.reduce((a, b) => a.value >= b.value ? a : b);
    if (best.value < minDeviationVotes) return null;
    return (platform: best.key, votes: best.value);
  }

  static List<PlatformShiftPlanBlock> _mergeConsecutive(
    List<PlatformShiftPlanBlock> blocks,
  ) {
    if (blocks.isEmpty) return const [];

    final merged = <PlatformShiftPlanBlock>[blocks.first];
    for (var i = 1; i < blocks.length; i++) {
      final current = blocks[i];
      final last = merged.last;
      if (last.platform == current.platform && last.endHour == current.startHour) {
        merged[merged.length - 1] = PlatformShiftPlanBlock(
          startHour: last.startHour,
          endHour: current.endHour,
          platform: last.platform,
          reason: last.reason,
          expectedRevenuePerHour: last.expectedRevenuePerHour,
        );
      } else {
        merged.add(current);
      }
    }
    return merged;
  }

  static int _blockHours(PlatformShiftPlanBlock block) {
    if (block.endHour <= block.startHour) {
      return (24 - block.startHour) + block.endHour;
    }
    return block.endHour - block.startHour;
  }
}
