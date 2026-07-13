import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/product_story.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Card de plano e upsell Pro no perfil.
class ProfilePlanCard extends StatelessWidget {
  const ProfilePlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

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
            'Seu plano',
            style: AppTypography.labelCaps(brightness),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'DriveFlow Gratuito',
            style: AppTypography.iosHeadline(brightness).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            ProductStory.proProfileSubtitle,
            style: AppTypography.iosBody(brightness).copyWith(
              color: AppColors.secondaryLabel(Theme.of(context)),
              height: 1.45,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...ProductStory.proFeatures.take(3).map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: AppColors.profitGreen,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          feature,
                          style: AppTypography.iosFootnote(brightness),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: AppSpacing.md),
          DfButton(
            label: 'Ver DriveFlow Pro',
            icon: Icons.workspace_premium_outlined,
            variant: DfButtonVariant.tonal,
            expand: false,
            onPressed: () => context.push(AppRoutes.paywall),
          ),
        ],
      ),
    );
  }
}
