import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/maintenance_prediction.dart';

/// Card premium de manutenção prevista com badges de confiança.
class MaintenancePredictionCard extends StatelessWidget {
  const MaintenancePredictionCard({
    required this.predictions,
    super.key,
  });

  final List<MaintenancePrediction> predictions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUrgent = predictions.any(
      (p) => p.daysUntilDue != null && p.daysUntilDue! <= 14,
    );

    return DfCard(
      variant: hasUrgent ? DfCardVariant.hero : DfCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.warningAmber.withValues(alpha: 0.14),
                  borderRadius: AppRadius.mdAll,
                ),
                child: const Icon(
                  Icons.build_circle_outlined,
                  color: AppColors.warningAmber,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Manutenção prevista',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (predictions.isEmpty)
            Text(
              'Cadastre manutenções com lembrete para ver previsões.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryLabel(theme),
                height: 1.45,
              ),
            )
          else
            ...predictions.take(3).map(
                  (prediction) => _PredictionRow(prediction: prediction),
                ),
        ],
      ),
    );
  }
}

class _PredictionRow extends StatelessWidget {
  const _PredictionRow({required this.prediction});

  final MaintenancePrediction prediction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final urgent = prediction.daysUntilDue != null &&
        prediction.daysUntilDue! <= 14;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: (urgent ? AppColors.warningAmber : AppColors.skyBlue)
              .withValues(alpha: 0.06),
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: (urgent ? AppColors.warningAmber : AppColors.skyBlue)
                .withValues(alpha: 0.18),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prediction.summaryLabel,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (prediction.averageKmPerDay != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Média ${prediction.averageKmPerDay!.toStringAsFixed(0)} km/dia',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryLabel(theme),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _ConfidenceBadge(
                label: prediction.confidence.label,
                urgent: urgent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({
    required this.label,
    required this.urgent,
  });

  final String label;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = urgent ? AppColors.warningAmber : AppColors.skyBlue;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
