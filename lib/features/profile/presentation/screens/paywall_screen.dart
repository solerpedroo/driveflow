import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/product_story.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';
import '../../../../shared/widgets/design_system/df_value_banner.dart';

/// Paywall storytelling — UI pronta; billing em onda futura.
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return DfSubpageScaffold(
      title: 'DriveFlow Pro',
      children: [
        DfValueBanner(
          title: ProductStory.proHeadline,
          subtitle: ProductStory.proPaywallSubtitle,
          icon: Icons.workspace_premium_rounded,
          variant: DfValueBannerVariant.insight,
        ),
        DfCard(
          variant: DfCardVariant.elevated,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'O que você desbloqueia',
                style: AppTypography.iosHeadline(brightness).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final feature in ProductStory.proFeatures)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 20,
                        color: AppColors.profitGreen,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          feature,
                          style: AppTypography.iosBody(brightness).copyWith(
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        DfCard(
          variant: DfCardVariant.elevated,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                ProductStory.proPriceLabel,
                textAlign: TextAlign.center,
                style: AppTypography.metric(
                  brightness,
                  fontSize: 36,
                  color: AppColors.brandBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ProductStory.proPriceDetail,
                textAlign: TextAlign.center,
                style: AppTypography.iosFootnote(brightness).copyWith(
                  color: AppColors.secondaryLabel(Theme.of(context)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              DfButton(
                label: 'Começar teste grátis de 7 dias',
                variant: DfButtonVariant.gradient,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Assinaturas em breve — estamos finalizando a integração.',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              DfButton(
                label: 'Continuar no plano gratuito',
                variant: DfButtonVariant.outlined,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
        Text(
          ProductStory.socialProofCount +
              ' ${ProductStory.socialProofLabel}',
          textAlign: TextAlign.center,
          style: AppTypography.iosFootnote(brightness).copyWith(
            color: AppColors.secondaryLabel(Theme.of(context)),
          ),
        ),
      ],
    );
  }
}
