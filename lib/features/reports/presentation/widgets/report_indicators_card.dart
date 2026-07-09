import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/report_snapshot.dart';

/// Card de indicadores do relatório por período.
class ReportIndicatorsCard extends StatelessWidget {
  const ReportIndicatorsCard({
    required this.report,
    super.key,
  });

  final ReportSnapshot report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = report.summary;
    final profitColor = summary.profit >= 0
        ? AppColors.profitGreen
        : AppColors.expenseCoral;

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Indicadores — ${report.periodLabel}',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          _IndicatorRow(
            label: 'Receita',
            value: CurrencyFormatter.format(summary.revenue),
          ),
          _IndicatorRow(
            label: 'Despesas',
            value: CurrencyFormatter.format(summary.expenses),
          ),
          _IndicatorRow(
            label: 'Lucro',
            value: CurrencyFormatter.formatSigned(summary.profit),
            valueColor: profitColor,
          ),
          _IndicatorRow(
            label: 'Horas',
            value: DurationFormatter.formatWorkedHours(summary.workedHours),
          ),
          _IndicatorRow(label: 'Corridas', value: '${summary.rides}'),
          _IndicatorRow(
            label: 'Km estimados',
            value: summary.kmDriven > 0
                ? summary.kmDriven.toStringAsFixed(0)
                : '—',
          ),
          _IndicatorRow(
            label: 'Combustível',
            value: CurrencyFormatter.format(summary.fuelExpense),
          ),
          if (summary.profitPerHour != null)
            _IndicatorRow(
              label: 'Lucro / hora',
              value: CurrencyFormatter.format(summary.profitPerHour!),
            ),
          if (summary.profitPerKm != null)
            _IndicatorRow(
              label: 'Lucro / km',
              value: CurrencyFormatter.format(summary.profitPerKm!),
            ),
        ],
      ),
    );
  }
}

class _IndicatorRow extends StatelessWidget {
  const _IndicatorRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryLabel(theme),
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
