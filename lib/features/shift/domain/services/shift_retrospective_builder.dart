import '../../../../core/constants/ride_platforms.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../entities/shift_block_outcome.dart';
import '../entities/shift_coach_insight.dart';
import '../entities/shift_history_entry.dart';
import '../entities/shift_retrospective.dart';
import '../entities/shift_session_entity.dart';
import '../entities/shift_session_plan_block.dart';
import '../entities/shift_session_status.dart';
import 'shift_coach_analyzer.dart';
import 'shift_session_aggregator.dart';

/// Monta retrospectiva narrativa e breakdown a partir do histórico.
abstract final class ShiftRetrospectiveBuilder {
  static ShiftRetrospective build({
    required ShiftHistoryEntry entry,
    List<EarningEntity> earnings = const [],
    ShiftCoachInsight? weeklyPattern,
  }) {
    final platformBreakdown = _platformBreakdown(entry.revenueByPlatform);
    final blockOutcomes = entry.blockOutcomes.isNotEmpty
        ? entry.blockOutcomes
        : _blockOutcomesFromLiveEarnings(entry: entry, earnings: earnings);

    return ShiftRetrospective(
      entry: entry,
      platformBreakdown: platformBreakdown,
      blockOutcomes: blockOutcomes,
      insight: ShiftCoachAnalyzer.retrospectiveInsight(
        entry: entry,
        weeklyPattern: weeklyPattern,
      ),
    );
  }

  static List<ShiftBlockOutcome> computeBlockOutcomesForSession({
    required ShiftSessionEntity session,
    required List<EarningEntity> earnings,
    String? vehicleId,
  }) {
    final completed = session.status == ShiftSessionStatus.completed
        ? session
        : session.copyWith(
            status: ShiftSessionStatus.completed,
            endedAt: session.endedAt ?? DateTime.now(),
          );

    final entry = ShiftHistoryEntry(
      id: session.id,
      userId: '',
      startedAt: session.startedAt,
      endedAt: completed.endedAt ?? DateTime.now(),
      elapsed: completed.elapsedAt(completed.endedAt ?? DateTime.now()),
      accumulatedPause: session.accumulatedPause,
      isTaxiMode: session.isTaxiMode,
      vehicleId: vehicleId ?? session.vehicleId,
      revenue: 0,
      rides: 0,
      adherenceScore: 0,
      matchedPlanBlocks: 0,
      totalPlanBlocks: session.planBlocks.length,
      planBlocks: session.planBlocks,
      revenueByPlatform: const {},
    );

    return _blockOutcomesFromLiveEarnings(entry: entry, earnings: earnings);
  }

  static List<ShiftPlatformSlice> _platformBreakdown(
    Map<RidePlatform, double> totals,
  ) {
    if (totals.isEmpty) return const [];

    final revenue = totals.values.fold<double>(0, (sum, value) => sum + value);
    final slices = totals.entries
        .map(
          (entry) => ShiftPlatformSlice(
            platform: entry.key,
            revenue: entry.value,
            share: revenue > 0 ? entry.value / revenue : 0,
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    return slices;
  }

  static List<ShiftBlockOutcome> _blockOutcomesFromLiveEarnings({
    required ShiftHistoryEntry entry,
    required List<EarningEntity> earnings,
  }) {
    if (entry.planBlocks.isEmpty) return const [];

    final session = ShiftSessionEntity(
      id: entry.id,
      startedAt: entry.startedAt,
      endedAt: entry.endedAt,
      status: ShiftSessionStatus.completed,
      planBlocks: entry.planBlocks,
      isTaxiMode: entry.isTaxiMode,
      vehicleId: entry.vehicleId,
      accumulatedPause: entry.accumulatedPause,
    );

    final scoped = ShiftSessionAggregator.earningsInSession(
      session: session,
      earnings: earnings,
      vehicleId: entry.vehicleId,
    );

    return entry.planBlocks.map((block) {
      final blockEarnings = scoped.where((earning) {
        final anchor = earning.createdAt ?? earning.date;
        return block.containsHour(anchor.hour);
      }).toList(growable: false);

      if (blockEarnings.isEmpty) {
        return ShiftBlockOutcome(
          block: block,
          actualPlatform: null,
          matched: false,
          revenue: 0,
        );
      }

      final totals = <RidePlatform, double>{};
      for (final earning in blockEarnings) {
        totals[earning.platform] =
            (totals[earning.platform] ?? 0) + earning.amount;
      }

      final dominant = totals.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;

      return ShiftBlockOutcome(
        block: block,
        actualPlatform: dominant,
        matched: dominant == block.platform,
        revenue: totals.values.fold<double>(0, (sum, value) => sum + value),
      );
    }).toList(growable: false);
  }
}
