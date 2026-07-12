import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/services/goal_progress_calculator.dart';

/// Card de meta — módulo elevado no padrão Início.
class GoalProgressCard extends StatelessWidget {
  const GoalProgressCard({
    required this.progress,
    super.key,
    this.onTap,
    this.hideValue = false,
  });

  final GoalProgress progress;
  final VoidCallback? onTap;
  final bool hideValue;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final fraction = progress.hasTarget
        ? (progress.progressPercent / 100).clamp(0.0, 1.0)
        : 0.0;
    final accent =
        progress.isComplete ? AppColors.profitGreen : AppColors.brandBlue;

    return DfCard(
      variant: DfCardVariant.elevated,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
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
                  style: AppTypography.iosHeadline(brightness).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                hideValue
                    ? maskPlain(progress.progressLabel, hidden: true)
                    : progress.progressLabel,
                style: AppTypography.iosHeadline(brightness).copyWith(
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
                ? hideValue
                    ? 'Lucro ${maskCurrency(CurrencyFormatter.format(progress.actualProfit), hidden: true)} · Meta ${maskCurrency(CurrencyFormatter.format(progress.targetAmount), hidden: true)}'
                    : 'Lucro ${CurrencyFormatter.format(progress.actualProfit)} · Meta ${CurrencyFormatter.format(progress.targetAmount)}'
                : 'Configure uma meta para acompanhar o progresso',
            style: AppTypography.iosFootnote(brightness),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.brandBlue.withValues(alpha: 0.10),
                    ),
                  ),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.hasTarget ? fraction : 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: accent),
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
                  : hideValue
                      ? 'Faltam ${maskCurrency(CurrencyFormatter.format(progress.remainingAmount), hidden: true)}'
                      : 'Faltam ${CurrencyFormatter.format(progress.remainingAmount)}',
              style: AppTypography.iosCaption(brightness).copyWith(
                color: progress.isComplete
                    ? AppColors.profitGreen
                    : AppColors.secondaryLabel(Theme.of(context)),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
