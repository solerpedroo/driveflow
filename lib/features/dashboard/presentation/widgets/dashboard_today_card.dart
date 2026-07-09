import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../goals/domain/services/goal_progress_calculator.dart';
import '../../../../shared/domain/models/period_summary.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Card premium "Hoje" — ganhos, gastos, lucro e stats inline.
class DashboardTodayCard extends StatelessWidget {
  const DashboardTodayCard({
    required this.summary,
    required this.goalProgress,
    super.key,
  });

  final PeriodSummary summary;
  final GoalProgress goalProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profitColor =
        summary.profit >= 0 ? AppColors.profitGreen : AppColors.expenseCoral;

    return DfCard(
      variant: DfCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoje',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _MetricRow(
            label: 'Ganhos',
            value: CurrencyFormatter.format(summary.revenue),
            color: AppColors.profitGreen,
          ),
          _MetricRow(
            label: 'Gastos',
            value: CurrencyFormatter.format(summary.expenses),
            color: AppColors.expenseCoral,
          ),
          _MetricRow(
            label: 'Lucro',
            value: CurrencyFormatter.formatSigned(summary.profit),
            color: profitColor,
            emphasized: true,
          ),
          const Divider(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _InlineStat(
                icon: Icons.schedule_rounded,
                label: 'Horas',
                value: DurationFormatter.formatWorkedHours(summary.workedHours),
                color: AppColors.infoBlue,
              ),
              _InlineStat(
                icon: Icons.route_rounded,
                label: 'Km',
                value: summary.kmDriven > 0
                    ? summary.kmDriven.toStringAsFixed(0)
                    : '—',
                color: AppColors.skyBlue,
              ),
              _InlineStat(
                icon: Icons.local_taxi_rounded,
                label: 'Corridas',
                value: '${summary.rides}',
                color: AppColors.profitGreen,
              ),
              _InlineStat(
                icon: Icons.flag_rounded,
                label: 'Meta',
                value: goalProgress.progressLabel,
                color: AppColors.warningAmber,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    required this.color,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
            style: (emphasized
                    ? theme.textTheme.titleMedium
                    : theme.textTheme.bodyLarge)
                ?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineStat extends StatelessWidget {
  const _InlineStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Semantics(
        label: '$label: $value',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              '$label $value',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
