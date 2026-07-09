import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Cabeçalho narrativo da tela de insights — vende recomendações inteligentes.
class InsightsStoryHeader extends StatelessWidget {
  const InsightsStoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DfCard(
      variant: DfCardVariant.hero,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.profitGreen, AppColors.skyBlue],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seu copiloto operacional',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Descubra o melhor horário para rodar, antecipe manutenções '
                  'e saiba se está no ritmo da meta semanal.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
