import '../../../../core/constants/ride_platforms.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../entities/shift_history_entry.dart';
import '../entities/shift_retrospective.dart';
import '../entities/shift_session_entity.dart';
import '../entities/shift_session_status.dart';
import 'shift_session_aggregator.dart';

/// Monta retrospectiva narrativa e breakdown a partir do histórico.
abstract final class ShiftRetrospectiveBuilder {
  static ShiftRetrospective build({
    required ShiftHistoryEntry entry,
    required List<EarningEntity> earnings,
  }) {
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

    final platformBreakdown = _platformBreakdown(entry.revenueByPlatform);
    final blockOutcomes = _blockOutcomes(
      entry: entry,
      earnings: scoped,
    );

    return ShiftRetrospective(
      entry: entry,
      platformBreakdown: platformBreakdown,
      blockOutcomes: blockOutcomes,
      insight: _insight(entry),
    );
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

  static List<ShiftBlockOutcome> _blockOutcomes({
    required ShiftHistoryEntry entry,
    required List<EarningEntity> earnings,
  }) {
    if (entry.planBlocks.isEmpty) return const [];

    return entry.planBlocks.map((block) {
      final blockEarnings = earnings.where((earning) {
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

  static String _insight(ShiftHistoryEntry entry) {
    if (entry.totalPlanBlocks == 0) {
      return entry.revenuePerHour == null
          ? 'Turno registrado. Continue capturando ganhos para ver R\$/h.'
          : 'Você faturou com média de '
              '${entry.revenuePerHour!.toStringAsFixed(0)}/h neste turno.';
    }

    if (entry.adherenceScore >= 80) {
      return 'Excelente aderência ao plano (${entry.adherenceScore.round()}%). '
          'Seu mix seguiu o histórico.';
    }
    if (entry.adherenceScore >= 50) {
      return 'Aderência moderada (${entry.adherenceScore.round()}%). '
          'Alguns blocos fugiram do plano — vale revisar o heatmap.';
    }
    return 'Baixa aderência (${entry.adherenceScore.round()}%). '
        'Considere ajustar o plano ou capturar ganhos por app com mais frequência.';
  }
}
