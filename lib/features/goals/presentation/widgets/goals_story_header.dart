import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Cabeçalho narrativo da tela de metas — vende o valor das metas financeiras.
class GoalsStoryHeader extends StatelessWidget {
  const GoalsStoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DfCard(
      variant: DfCardVariant.hero,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suas metas são seu volante',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Defina quanto quer lucrar por dia, semana ou mês — '
            'e acompanhe no anel do dashboard em tempo real.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryLabel(theme),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
