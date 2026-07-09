import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/product_story.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Card de plano no perfil — vende assinatura Pro com comparativo visual.
class ProfilePlanCard extends StatelessWidget {
  const ProfilePlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DfCard(
      variant: DfCardVariant.hero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_rounded, color: AppColors.skyBlue),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  ProductStory.proHeadline,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mutedSurface(theme),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Grátis',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            ProductStory.proSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryLabel(theme),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final feature in ProductStory.proFeatures.take(3)) ...[
            Row(
              children: [
                Icon(feature.icon, size: 18, color: AppColors.skyBlue),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    feature.title,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: AppColors.secondaryLabel(theme),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.md),
          DfButton(
            label: 'Upgrade para Pro',
            icon: Icons.arrow_forward_rounded,
            variant: DfButtonVariant.gradient,
            onPressed: () => context.push(AppRoutes.paywall),
          ),
        ],
      ),
    );
  }
}
