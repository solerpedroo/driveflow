import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/shift_analytics_summary.dart';

/// Grade de KPIs principais dos turnos.
class ShiftAnalyticsKpiGrid extends StatelessWidget {
  const ShiftAnalyticsKpiGrid({
    required this.summary,
    required this.hideValues,
    super.key,
  });

  final ShiftAnalyticsSummary summary;
  final bool hideValues;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hours = summary.avgDuration.inMinutes / 60;

    return DfCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _KpiCell(
                  label: 'Turnos',
                  value: '${summary.shiftCount}',
                  theme: theme,
                ),
              ),
              Expanded(
                child: _KpiCell(
                  label: 'Faturamento',
                  value: hideValues
                      ? '•••'
                      : CurrencyFormatter.format(summary.totalRevenue),
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _KpiCell(
                  label: 'R\$/h médio',
                  value: hideValues
                      ? '•••'
                      : summary.avgRevenuePerHour > 0
                          ? CurrencyFormatter.format(summary.avgRevenuePerHour)
                          : '—',
                  theme: theme,
                ),
              ),
              Expanded(
                child: _KpiCell(
                  label: 'Aderência',
                  value: summary.avgAdherence > 0
                      ? '${summary.avgAdherence.round()}%'
                      : '—',
                  theme: theme,
                  accent: true,
                ),
              ),
            ],
          ),
          if (hours > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Duração média ${hours.toStringAsFixed(1)}h · '
                '${summary.totalRides} corridas',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryLabel(theme),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KpiCell extends StatelessWidget {
  const _KpiCell({
    required this.label,
    required this.value,
    required this.theme,
    this.accent = false,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.secondaryLabel(theme),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: accent ? AppColors.brandBlue : null,
          ),
        ),
      ],
    );
  }
}
