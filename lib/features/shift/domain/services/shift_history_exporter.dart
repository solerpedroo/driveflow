import '../../../../core/utils/csv_escape.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../entities/shift_history_entry.dart';

/// Exporta histórico de turnos em CSV.
abstract final class ShiftHistoryExporter {
  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  static String buildCsv(List<ShiftHistoryEntry> entries) {
    final lines = <String>[
      csvRow([
        'Início',
        'Fim',
        'Duração',
        'Ganhos',
        'Despesas',
        'Líquido',
        'Corridas',
        'R\$/h',
        'Aderência %',
        'Blocos ok',
        'Blocos total',
        'Taxista',
        'Top app',
      ]),
    ];

    for (final entry in entries) {
      final topPlatform = entry.revenueByPlatform.entries.isEmpty
          ? ''
          : entry.revenueByPlatform.entries
              .reduce((a, b) => a.value >= b.value ? a : b)
              .key
              .label;

      lines.add(
        csvRow([
          entry.startedAt.toIso8601String(),
          entry.endedAt.toIso8601String(),
          _formatDuration(entry.elapsed),
          CurrencyFormatter.format(entry.revenue),
          CurrencyFormatter.format(entry.expenses),
          CurrencyFormatter.formatSigned(entry.netCash),
          '${entry.rides}',
          entry.revenuePerHour == null
              ? ''
              : CurrencyFormatter.format(entry.revenuePerHour!),
          entry.adherenceScore.toStringAsFixed(1),
          '${entry.matchedPlanBlocks}',
          '${entry.totalPlanBlocks}',
          entry.isTaxiMode ? 'sim' : 'não',
          topPlatform,
        ]),
      );
    }

    return lines.join('\n');
  }
}
