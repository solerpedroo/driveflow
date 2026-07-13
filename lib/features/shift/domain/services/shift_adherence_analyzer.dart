import '../../../earnings/domain/entities/earning_entity.dart';
import '../../../../core/constants/ride_platforms.dart';
import '../entities/shift_adherence_result.dart';
import '../entities/shift_session_entity.dart';
import '../entities/shift_session_plan_block.dart';
import 'shift_session_aggregator.dart';

/// Calcula aderência do turno ao plano horário por plataforma.
abstract final class ShiftAdherenceAnalyzer {
  static ShiftAdherenceResult analyze({
    required ShiftSessionEntity session,
    required List<EarningEntity> earnings,
  }) {
    if (session.planBlocks.isEmpty) return ShiftAdherenceResult.perfect;

    final scoped = ShiftSessionAggregator.earningsInSession(
      session: session,
      earnings: earnings,
      vehicleId: session.vehicleId,
    );

    var matched = 0;
    for (final block in session.planBlocks) {
      final blockEarnings = scoped.where((earning) {
        final anchor = earning.createdAt ?? earning.date;
        return block.containsHour(anchor.hour);
      }).toList(growable: false);

      if (blockEarnings.isEmpty) continue;

      final totals = <RidePlatform, double>{};
      for (final earning in blockEarnings) {
        totals[earning.platform] =
            (totals[earning.platform] ?? 0) + earning.amount;
      }

      final dominant = totals.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      if (dominant == block.platform) matched++;
    }

    final total = session.planBlocks.length;
    final score = total == 0 ? 100.0 : (matched / total) * 100;

    return ShiftAdherenceResult(
      score: score,
      matchedBlocks: matched,
      totalBlocks: total,
    );
  }
}
