import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/period_comparison_result.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Card com variação de indicadores vs período de referência.
class PeriodComparisonCard extends StatelessWidget {
  const PeriodComparisonCard({
    required this.comparison,
    super.key,
  });

  final PeriodComparisonResult comparison;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparativo — ${comparison.period.label}',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'vs ${comparison.reference.label.toLowerCase()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryLabel(theme),
            ),
          ),
          const SizedBox(height: 12),
          ...comparison.metrics.map(
            (metric) => _MetricRow(metric: metric),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.metric});

  final PeriodMetricDelta metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMoney = !metric.label.contains('/ km') &&
        metric.label != 'Lucro / hora';

    final currentText = _formatValue(metric.current, isMoney: isMoney);
    final deltaColor = metric.improved
        ? AppColors.profitGreen
        : AppColors.expenseCoral;
    final deltaPrefix = metric.delta >= 0 ? '+' : '';
    final percentText = metric.deltaPercent != null
        ? ' (${deltaPrefix}${metric.deltaPercent!.toStringAsFixed(1)}%)'
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              metric.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryLabel(theme),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currentText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$deltaPrefix${_formatValue(metric.delta, isMoney: isMoney)}$percentText',
                style: theme.textTheme.labelSmall?.copyWith(color: deltaColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatValue(double value, {required bool isMoney}) {
    if (isMoney) {
      return CurrencyFormatter.format(value);
    }
    return value.toStringAsFixed(2);
  }
}
