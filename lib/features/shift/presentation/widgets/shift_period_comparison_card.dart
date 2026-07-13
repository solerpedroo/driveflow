import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/shift_period_comparison.dart';

/// Compara turnos do período atual com o anterior.
class ShiftPeriodComparisonCard extends StatelessWidget {
  const ShiftPeriodComparisonCard({
    required this.comparison,
    required this.periodLabel,
    super.key,
  });

  final ShiftPeriodComparison comparison;
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delta = comparison.revenueDeltaPercent;

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'vs período anterior',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            periodLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryLabel(theme),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _MetricRow(
            label: 'Faturamento',
            current: CurrencyFormatter.format(comparison.currentRevenue),
            delta: delta == null
                ? null
                : '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(0)}%',
            improved: delta == null ? null : delta >= 0,
            theme: theme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _MetricRow(
            label: 'Turnos',
            current: '${comparison.currentShifts}',
            delta: comparison.shiftDelta == 0
                ? '0'
                : '${comparison.shiftDelta >= 0 ? '+' : ''}${comparison.shiftDelta}',
            improved: comparison.shiftDelta >= 0,
            theme: theme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _MetricRow(
            label: 'Aderência média',
            current: '${comparison.currentAvgAdherence.round()}%',
            delta:
                '${comparison.adherenceDelta >= 0 ? '+' : ''}${comparison.adherenceDelta.round()} pp',
            improved: comparison.adherenceDelta >= 0,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.current,
    required this.delta,
    required this.improved,
    required this.theme,
  });

  final String label;
  final String current;
  final String? delta;
  final bool? improved;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final deltaColor = improved == null
        ? AppColors.secondaryLabel(theme)
        : improved!
            ? AppColors.profitGreen
            : AppColors.expenseCoral;

    return Row(
      children: [
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Text(
          current,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (delta != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            delta!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: deltaColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}
