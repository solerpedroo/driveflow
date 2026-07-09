import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/maintenance_prediction.dart';

/// Card de manutenção prevista com badge de confiança.
class MaintenancePredictionCard extends StatelessWidget {
  const MaintenancePredictionCard({
    required this.predictions,
    super.key,
  });

  final List<MaintenancePrediction> predictions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.build_circle_outlined,
                  color: AppColors.warningAmber),
              const SizedBox(width: 8),
              Text('Manutenção prevista', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 8),
          if (predictions.isEmpty)
            Text(
              'Cadastre manutenções com lembrete para ver previsões.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryLabel(theme),
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

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediction.summaryLabel,
                  style: theme.textTheme.bodyLarge,
                ),
                if (prediction.averageKmPerDay != null)
                  Text(
                    'Média ${prediction.averageKmPerDay!.toStringAsFixed(0)} km/dia',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryLabel(theme),
                    ),
                  ),
              ],
            ),
          ),
          Chip(
            label: Text(prediction.confidence.label),
            visualDensity: VisualDensity.compact,
            backgroundColor: AppColors.electricTeal.withValues(alpha: 0.12),
          ),
        ],
      ),
    );
  }
}
