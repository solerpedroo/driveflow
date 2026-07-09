import 'package:flutter/material.dart';

import '../../../goals/domain/services/goal_progress_calculator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../shared/domain/models/period_summary.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_hero_metric.dart';
import '../../../../shared/widgets/design_system/df_progress_ring.dart';

/// Hero do dashboard — anel de meta + lucro central (padrão FitCal calorie ring).
class DashboardHeroSection extends StatelessWidget {
  const DashboardHeroSection({
    required this.summary,
    required this.goalProgress,
    required this.greeting,
    super.key,
  });

  final PeriodSummary summary;
  final GoalProgress goalProgress;
  final String greeting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profitColor = summary.profit >= 0
        ? AppSemanticColors.success
        : AppSemanticColors.error;
    final ringProgress = goalProgress.hasTarget
        ? (goalProgress.progressPercent / 100).clamp(0.0, 1.0)
        : 0.0;
    final ringColor = goalProgress.isComplete
        ? AppSemanticColors.success
        : AppColors.skyBlue;

    return DfCard(
      variant: DfCardVariant.hero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryLabel(theme),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Seu lucro hoje',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: DfProgressRing(
              progress: ringProgress,
              size: 196,
              strokeWidth: 12,
              accentColor: ringColor,
              child: DfHeroMetric(
                value: CurrencyFormatter.formatSigned(summary.profit),
                label: goalProgress.hasTarget
                    ? 'Meta ${goalProgress.progressLabel}'
                    : 'Lucro do dia',
                valueColor: profitColor,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _MacroPill(
                  label: 'Ganhos',
                  value: CurrencyFormatter.format(summary.revenue),
                  color: AppSemanticColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MacroPill(
                  label: 'Gastos',
                  value: CurrencyFormatter.format(summary.expenses),
                  color: AppSemanticColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _StatChip(
                icon: Icons.schedule_rounded,
                label: DurationFormatter.formatWorkedHours(summary.workedHours),
              ),
              _StatChip(
                icon: Icons.route_rounded,
                label: summary.kmDriven > 0
                    ? '${summary.kmDriven.toStringAsFixed(0)} km'
                    : '— km',
              ),
              _StatChip(
                icon: Icons.local_taxi_rounded,
                label: '${summary.rides} corridas',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  const _MacroPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.secondaryLabel(theme),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.mutedSurface(theme),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.skyBlue),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}
