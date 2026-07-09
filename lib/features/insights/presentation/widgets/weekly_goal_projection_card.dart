import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/weekly_goal_projection.dart';

/// Card premium de projeção da meta semanal.
class WeeklyGoalProjectionCard extends StatelessWidget {
  const WeeklyGoalProjectionCard({
    required this.projection,
    super.key,
  });

  final WeeklyGoalProjection projection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = projection.hasTarget
        ? (projection.progressPercent / 100).clamp(0.0, 1.0)
        : 0.0;
    final accent =
        projection.onTrack ? AppColors.profitGreen : AppColors.warningAmber;

    return DfCard(
      variant: projection.onTrack && projection.hasTarget
          ? DfCardVariant.hero
          : DfCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.skyBlue.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.flag_outlined,
                  color: AppColors.skyBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Projeção semanal',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (!projection.hasTarget)
            Text(
              'Configure uma meta semanal para ver a projeção.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryLabel(theme),
                height: 1.45,
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _StatBlock(
                    label: 'Lucro atual',
                    value: CurrencyFormatter.format(projection.actualProfit),
                    color: AppColors.profitGreen,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _StatBlock(
                    label: 'Projeção',
                    value: CurrencyFormatter.format(projection.projectedProfit),
                    color: accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Meta: ${CurrencyFormatter.format(projection.targetAmount)}',
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
                      widthFactor: fraction,
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
            const SizedBox(height: AppSpacing.sm),
            Text(
              projection.onTrack
                  ? 'No ritmo para bater a meta'
                  : 'Abaixo do ritmo necessário',
              style: theme.textTheme.labelLarge?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
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
    final theme = Theme.of(context);

    return Column(
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
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
