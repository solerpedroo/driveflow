import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/platform_shift_recommendation.dart';

/// Hero de recomendação — melhor app para o turno atual.
class PlatformRecommendationHeroCard extends StatelessWidget {
  const PlatformRecommendationHeroCard({
    required this.recommendation,
    super.key,
  });

  final PlatformShiftRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DfCard(
      variant: DfCardVariant.hero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppGradients.brand,
              borderRadius: AppRadius.mdAll,
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Melhor app agora: ${recommendation.recommended.label}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation.reason,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                    height: 1.4,
                  ),
                ),
                if (recommendation.bestHourSlot != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Turno: ${recommendation.bestHourSlot} · '
                    'Confiança ${(recommendation.confidence * 100).round()}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.brandBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
