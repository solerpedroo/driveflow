import '../../../../core/constants/ride_platforms.dart';
import '../entities/shift_coach_insight.dart';
import '../entities/shift_history_entry.dart';

/// Analisa padrões de aderência e desvios nos turnos recentes.
abstract final class ShiftCoachAnalyzer {
  static const defaultLookback = 8;

  static ShiftCoachInsight? analyze({
    required List<ShiftHistoryEntry> history,
    int maxEntries = defaultLookback,
  }) {
    final recent = history
        .where((entry) => entry.totalPlanBlocks > 0 || entry.revenue > 0)
        .take(maxEntries)
        .toList(growable: false);
    if (recent.isEmpty) return null;

    final avgAdherence = recent.fold<double>(
          0,
          (sum, entry) => sum + entry.adherenceScore,
        ) /
        recent.length;

    final platformRevenue = <RidePlatform, double>{};
    for (final entry in recent) {
      entry.revenueByPlatform.forEach((platform, amount) {
        platformRevenue[platform] = (platformRevenue[platform] ?? 0) + amount;
      });
    }

    RidePlatform? preferredPlatform;
    if (platformRevenue.isNotEmpty) {
      preferredPlatform = platformRevenue.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    final deviationCounts = <String, int>{};
    final deviationHours = <int, int>{};
    for (final entry in recent) {
      for (final outcome in entry.blockOutcomes) {
        if (outcome.matched || outcome.actualPlatform == null) continue;
        final hour = outcome.block.startHour;
        final platform = outcome.actualPlatform!;
        final key = '$hour:${platform.value}';
        deviationCounts[key] = (deviationCounts[key] ?? 0) + 1;
        deviationHours[hour] = (deviationHours[hour] ?? 0) + 1;
      }
    }

    int? typicalDeviationHour;
    RidePlatform? typicalDeviationPlatform;
    var topDeviationCount = 0;
    deviationCounts.forEach((key, count) {
      if (count <= topDeviationCount) return;
      topDeviationCount = count;
      final parts = key.split(':');
      typicalDeviationHour = int.tryParse(parts.first);
      typicalDeviationPlatform = RidePlatform.fromValue(parts.last);
    });

    final tips = <String>[];
    if (avgAdherence < 50 && preferredPlatform != null) {
      tips.add(
        'Tente manter ${preferredPlatform.label} nos blocos sugeridos — '
        'é onde você mais faturou nos últimos turnos.',
      );
    } else if (avgAdherence >= 80) {
      tips.add(
        'Ótima aderência recente. O plano adaptativo mantém o que já funciona.',
      );
    }

    if (typicalDeviationHour != null &&
        typicalDeviationPlatform != null &&
        topDeviationCount >= 2) {
      tips.add(
        'Você costuma usar ${typicalDeviationPlatform!.label} por volta das '
        '${typicalDeviationHour!.toString().padLeft(2, '0')}h — '
        'ajustamos o próximo plano para isso.',
      );
    }

    if (tips.isEmpty && preferredPlatform != null) {
      tips.add(
        '${preferredPlatform.label} liderou seu faturamento nos últimos '
        '${recent.length} turnos.',
      );
    }

    final headline = avgAdherence >= 80
        ? 'Padrão forte nos últimos turnos'
        : avgAdherence >= 50
            ? 'Há espaço para alinhar melhor o plano'
            : 'Seu histórico sugere ajustes no mix';

    final detail = preferredPlatform == null
        ? 'Analisamos ${recent.length} turnos com aderência média de '
            '${avgAdherence.round()}%.'
        : 'Nos últimos ${recent.length} turnos, aderência média de '
            '${avgAdherence.round()}% e destaque para '
            '${preferredPlatform.label}.';

    return ShiftCoachInsight(
      shiftsAnalyzed: recent.length,
      avgAdherence: avgAdherence,
      headline: headline,
      detail: detail,
      tips: tips,
      preferredPlatform: preferredPlatform,
      typicalDeviationHour: typicalDeviationHour,
      typicalDeviationPlatform: typicalDeviationPlatform,
    );
  }

  /// Insight pós-turno acionável, enriquecido com padrão semanal.
  static String retrospectiveInsight({
    required ShiftHistoryEntry entry,
    ShiftCoachInsight? weeklyPattern,
  }) {
    if (entry.totalPlanBlocks == 0) {
      return entry.revenuePerHour == null
          ? 'Turno registrado. Continue capturando ganhos para ver R\$/h.'
          : 'Você faturou com média de '
              '${entry.revenuePerHour!.toStringAsFixed(0)}/h neste turno.';
    }

    final mismatches = entry.blockOutcomes
        .where((outcome) => !outcome.matched && outcome.actualPlatform != null)
        .toList(growable: false);

    if (entry.adherenceScore >= 80) {
      var message =
          'Excelente aderência (${entry.adherenceScore.round()}%). '
          'Repita o mesmo mix no próximo turno.';
      if (weeklyPattern != null && weeklyPattern.avgAdherence >= 70) {
        message += ' Sua consistência semanal está em alta.';
      }
      return message;
    }

    if (mismatches.isNotEmpty) {
      final top = mismatches.first;
      final hour = top.block.startHour.toString().padLeft(2, '0');
      return 'No bloco das ${hour}h você usou ${top.actualPlatform!.label} '
          'em vez de ${top.block.platform.label}. '
          'No próximo turno, siga o app sugerido ou aceite o plano adaptado.';
    }

    if (entry.adherenceScore >= 50) {
      return 'Aderência moderada (${entry.adherenceScore.round()}%). '
          'Revise o card de sugestão antes de iniciar o próximo turno.';
    }

    return 'Baixa aderência (${entry.adherenceScore.round()}%). '
        'Use o plano adaptativo na próxima saída — ele considera seus desvios.';
  }
}
