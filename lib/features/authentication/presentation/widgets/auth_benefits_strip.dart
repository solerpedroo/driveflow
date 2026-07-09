import 'package:flutter/material.dart';

import '../../../../core/constants/product_story.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Lista de benefícios do produto — storytelling no fluxo de auth.
class AuthBenefitsStrip extends StatelessWidget {
  const AuthBenefitsStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final benefit in ProductStory.authBenefits) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.skyBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(benefit.icon, size: 20, color: AppColors.skyBlue),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      benefit.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      benefit.detail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryLabel(theme),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Text(
          '${ProductStory.socialProofCount} ${ProductStory.socialProofLabel}',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.secondaryLabel(theme),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
