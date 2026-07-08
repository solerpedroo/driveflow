import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/services/goal_progress_calculator.dart';

/// Card de progresso de meta com barra linear e semantics.
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
        : AppColors.warningAmber;

    final semanticsLabel = progress.hasTarget
        ? '${progress.period.label}: ${progress.progressLabel} do lucro de '
            '${CurrencyFormatter.format(progress.actualProfit)} '
            'sobre meta de ${CurrencyFormatter.format(progress.targetAmount)}'
        : '${progress.period.label}: meta não configurada';

    return Semantics(
      label: semanticsLabel,
      button: onTap != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        progress.period.label,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      progress.progressLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  progress.hasTarget
                      ? 'Lucro ${CurrencyFormatter.format(progress.actualProfit)} · '
                          'Meta ${CurrencyFormatter.format(progress.targetAmount)}'
                      : 'Configure uma meta para acompanhar o progresso',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.hasTarget ? fraction : null,
                    minHeight: 8,
                    backgroundColor: AppColors.mutedSurface(theme),
                    color: accent,
                  ),
                ),
                if (progress.hasTarget) ...[
                  const SizedBox(height: 8),
                  Text(
                    progress.isComplete
                        ? 'Meta atingida!'
                        : 'Faltam ${CurrencyFormatter.format(progress.remainingAmount)}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: progress.isComplete
                          ? AppColors.profitGreen
                          : AppColors.secondaryLabel(theme),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
