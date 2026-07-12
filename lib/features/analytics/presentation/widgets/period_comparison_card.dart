import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../domain/entities/period_comparison_result.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Comparativo vs período de referência — módulo elevado.
class PeriodComparisonCard extends StatelessWidget {
  const PeriodComparisonCard({
    required this.comparison,
    this.hideValue = false,
    super.key,
  });

  final PeriodComparisonResult comparison;
  final bool hideValue;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return DfCard(
      variant: DfCardVariant.elevated,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparação',
            style: AppTypography.labelCaps(brightness),
          ),
          const SizedBox(height: 4),
          Text(
            '${comparison.period.label} vs ${comparison.reference.label.toLowerCase()}',
            style: AppTypography.iosFootnote(brightness),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < comparison.metrics.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 0.5,
                color: AppElevation.hairline(brightness).color,
              ),
            _MetricRow(
              metric: comparison.metrics[i],
              hideValue: hideValue,
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.metric,
    required this.hideValue,
  });

  final PeriodMetricDelta metric;
  final bool hideValue;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isMoney =
        !metric.label.contains('/ km') && metric.label != 'Lucro / hora';

    final currentText = hideValue
        ? (isMoney
            ? maskCurrency('', hidden: true)
            : maskPlain('', hidden: true))
        : _formatValue(metric.current, isMoney: isMoney);
    final deltaColor =
        metric.improved ? AppColors.profitGreen : AppColors.expenseCoral;
    final deltaPrefix = metric.delta >= 0 ? '+' : '';
    final percentText = metric.deltaPercent != null
        ? ' (${deltaPrefix}${metric.deltaPercent!.toStringAsFixed(1)}%)'
        : '';
    final deltaText = hideValue
        ? maskPlain('', hidden: true)
        : '$deltaPrefix${_formatValue(metric.delta, isMoney: isMoney)}$percentText';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              metric.label,
              style: AppTypography.iosBody(brightness).copyWith(
                color: AppColors.secondaryLabel(Theme.of(context)),
                fontSize: 15,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currentText,
                style: AppTypography.iosHeadline(brightness).copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                deltaText,
                style: AppTypography.iosCaption(brightness).copyWith(
                  color: hideValue
                      ? AppColors.secondaryLabel(Theme.of(context))
                      : deltaColor,
                  fontWeight: FontWeight.w600,
                ),
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
