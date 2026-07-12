import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/weekly_goal_projection.dart';

/// Projeção da meta semanal — módulo elevado.
class WeeklyGoalProjectionCard extends StatelessWidget {
  const WeeklyGoalProjectionCard({
    required this.projection,
    this.hideValue = false,
    super.key,
  });

  final WeeklyGoalProjection projection;
  final bool hideValue;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final fraction = projection.hasTarget
        ? (projection.progressPercent / 100).clamp(0.0, 1.0)
        : 0.0;
    final accent =
        projection.onTrack ? AppColors.profitGreen : AppColors.warningAmber;

    return DfCard(
      variant: DfCardVariant.elevated,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meta semanal',
            style: AppTypography.labelCaps(brightness),
          ),
          const SizedBox(height: 4),
          Text(
            'Projeção',
            style: AppTypography.iosHeadline(brightness).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!projection.hasTarget)
            Text(
              'Configure uma meta semanal para ver a projeção.',
              style: AppTypography.iosBody(brightness).copyWith(
                color: AppColors.secondaryLabel(Theme.of(context)),
                height: 1.45,
                fontSize: 15,
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _StatBlock(
                    label: 'Lucro atual',
                    value: hideValue
                        ? 'R\$ ••••••'
                        : CurrencyFormatter.format(projection.actualProfit),
                    color: AppColors.profitGreen,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _StatBlock(
                    label: 'Projeção',
                    value: hideValue
                        ? 'R\$ ••••••'
                        : CurrencyFormatter.format(projection.projectedProfit),
                    color: accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hideValue
                  ? 'Meta: •••••'
                  : 'Meta: ${CurrencyFormatter.format(projection.targetAmount)}',
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
                      widthFactor: fraction,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: accent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              projection.onTrack
                  ? 'No ritmo para bater a meta'
                  : 'Abaixo do ritmo necessário',
              style: AppTypography.iosCaption(brightness).copyWith(
                color: accent,
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

class _StatBlock extends StatelessWidget {
  const _StatBlock({
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.iosCaption(brightness),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.iosHeadline(brightness).copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
