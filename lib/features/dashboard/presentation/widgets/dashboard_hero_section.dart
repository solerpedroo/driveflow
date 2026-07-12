import 'package:flutter/material.dart';

import '../../../goals/domain/services/goal_progress_calculator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/utils/story_metrics.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/domain/models/daily_profit_point.dart';
import '../../../../shared/domain/models/period_summary.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_hero_metric.dart';
import '../../../../shared/widgets/design_system/df_progress_ring.dart';

/// Seção Hoje — secundária ao hero do mês (anel + narrativa do dia).
class DashboardHeroSection extends StatelessWidget {
  const DashboardHeroSection({
    required this.summary,
    required this.goalProgress,
    required this.weekProfits,
    this.hideValue = false,
    super.key,
  });

  final PeriodSummary summary;
  final GoalProgress goalProgress;
  final List<DailyProfitPoint> weekProfits;
  final bool hideValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final profitColor = summary.profit >= 0
        ? AppSemanticColors.success
        : AppSemanticColors.error;
    final ringProgress = goalProgress.hasTarget
        ? (goalProgress.progressPercent / 100).clamp(0.0, 1.0)
        : 0.0;
    final ringColor = goalProgress.isComplete
        ? AppSemanticColors.success
        : AppColors.brandBlue;
    final storyLine = hideValue
        ? 'Acompanhe lucro e meta do dia em tempo real'
        : StoryMetrics.heroSubtitle(
            today: summary,
            goalProgress: goalProgress,
            weekProfits: weekProfits,
          );
    final profitDisplay = maskCurrency(
      CurrencyFormatter.formatSigned(summary.profit),
      hidden: hideValue,
    );
    final goalLabel = goalProgress.hasTarget
        ? 'Meta ${maskPlain(goalProgress.progressLabel, hidden: hideValue)}'
        : 'Lucro do dia';

    return DfCard(
      variant: DfCardVariant.glass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOJE',
            style: AppTypography.labelCaps(brightness).copyWith(
              color: AppColors.secondaryLabel(theme),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            storyLine,
            style: AppTypography.iosBody(brightness).copyWith(
              color: AppColors.secondaryLabel(theme),
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: DfProgressRing(
              progress: ringProgress,
              size: 148,
              strokeWidth: 10,
              accentColor: ringColor,
              child: DfHeroMetric(
                value: profitDisplay,
                label: goalLabel,
                valueColor: profitColor,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _MacroPill(
                  label: 'Ganhos',
                  value: maskCurrency(
                    CurrencyFormatter.format(summary.revenue),
                    hidden: hideValue,
                  ),
                  color: AppSemanticColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MacroPill(
                  label: 'Gastos',
                  value: maskCurrency(
                    CurrencyFormatter.format(summary.expenses),
                    hidden: hideValue,
                  ),
                  color: AppSemanticColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
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
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.iosFootnote(brightness).copyWith(
              color: AppColors.secondaryLabel(Theme.of(context)),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.iosHeadline(brightness).copyWith(
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
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.mutedSurface(Theme.of(context)),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.brandBlue),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.iosFootnote(brightness).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
