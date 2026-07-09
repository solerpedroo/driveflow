import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/services/goal_progress_calculator.dart';

/// Card de meta premium — barra gradiente + DfCard.
class GoalProgressCard extends StatelessWidget {
  const GoalProgressCard({
    required this.progress,
    super.key,
    this.onTap,
  });

  final GoalProgress progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = progress.hasTarget
        ? (progress.progressPercent / 100).clamp(0.0, 1.0)
        : 0.0;
    final accent = progress.isComplete
        ? AppColors.profitGreen
        : AppColors.skyBlue;

    return DfCard(
      variant: progress.isComplete ? DfCardVariant.hero : DfCardVariant.glass,
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      semanticLabel: progress.hasTarget
          ? '${progress.period.label}: ${progress.progressLabel}'
          : '${progress.period.label}: meta não configurada',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  progress.period.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                progress.progressLabel,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            progress.hasTarget
                ? 'Lucro ${CurrencyFormatter.format(progress.actualProfit)} · Meta ${CurrencyFormatter.format(progress.targetAmount)}'
                : 'Configure uma meta para acompanhar o progresso',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryLabel(theme),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.mutedSurface(theme),
                    ),
                  ),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.hasTarget ? fraction : 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accent.withValues(alpha: 0.65),
                            accent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (progress.hasTarget) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              progress.isComplete
                  ? 'Meta atingida!'
                  : 'Faltam ${CurrencyFormatter.format(progress.remainingAmount)}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: progress.isComplete
                    ? AppColors.profitGreen
                    : AppColors.secondaryLabel(theme),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
