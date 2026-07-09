import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import 'df_button.dart';

/// Banner de valor — social proof, upsell ou narrativa de produto.
class DfValueBanner extends StatelessWidget {
  const DfValueBanner({
    required this.title,
    required this.subtitle,
    super.key,
    this.icon = Icons.auto_awesome_rounded,
    this.actionLabel,
    this.onAction,
    this.variant = DfValueBannerVariant.social,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final DfValueBannerVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPro = variant == DfValueBannerVariant.pro;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        gradient: isPro
            ? AppGradients.heroCardAccent(theme.brightness)
            : null,
        color: isPro
            ? null
            : AppColors.mutedSurface(theme),
        border: Border.all(
          color: isPro
              ? AppColors.skyBlue.withValues(alpha: 0.28)
              : AppColors.glassBorderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isPro ? AppColors.skyBlue : AppColors.profitGreen)
                    .withValues(alpha: 0.16),
                borderRadius: AppRadius.mdAll,
              ),
              child: Icon(
                icon,
                color: isPro ? AppColors.skyBlue : AppColors.profitGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryLabel(theme),
                      height: 1.4,
                    ),
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    DfButton(
                      label: actionLabel!,
                      onPressed: onAction,
                      variant: isPro
                          ? DfButtonVariant.gradient
                          : DfButtonVariant.tonal,
                      expand: false,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum DfValueBannerVariant { social, pro, insight }
