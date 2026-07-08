import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/driveflow_glass_card.dart';
import '../../domain/entities/weekly_goal_projection.dart';

/// Card de projeção da meta semanal.
class WeeklyGoalProjectionCard extends StatelessWidget {
  const WeeklyGoalProjectionCard({
    required this.projection,
    super.key,
  });

  final WeeklyGoalProjection projection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DriveFlowGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_outlined, color: AppColors.electricTeal),
              const SizedBox(width: 8),
              Text('Projeção semanal', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 8),
          if (!projection.hasTarget)
            Text(
              'Configure uma meta semanal para ver a projeção.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryLabel(theme),
              ),
            )
          else ...[
            Text(
              'Lucro atual: ${CurrencyFormatter.format(projection.actualProfit)}',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Projeção: ${CurrencyFormatter.format(projection.projectedProfit)} '
              'de ${CurrencyFormatter.format(projection.targetAmount)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryLabel(theme),
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (projection.progressPercent / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.secondaryLabel(theme).withValues(alpha: 0.2),
              color: projection.onTrack
                  ? AppColors.profitGreen
                  : AppColors.warningAmber,
            ),
            const SizedBox(height: 4),
            Text(
              projection.onTrack
                  ? 'No ritmo para bater a meta'
                  : 'Abaixo do ritmo necessário',
              style: theme.textTheme.labelMedium?.copyWith(
                color: projection.onTrack
                    ? AppColors.profitGreen
                    : AppColors.warningAmber,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
