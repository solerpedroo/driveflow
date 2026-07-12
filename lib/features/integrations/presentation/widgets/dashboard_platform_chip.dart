import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/platform_brand_icon.dart';
import '../../domain/entities/platform_shift_recommendation.dart';
import '../providers/integrations_providers.dart';

/// Recomendação de app — módulo elevado no dashboard.
class DashboardPlatformChip extends ConsumerWidget {
  const DashboardPlatformChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendation = ref.watch(platformShiftRecommendationProvider);

    return recommendation.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (rec) {
        if (rec == null) return const SizedBox.shrink();
        return _RecommendationCard(
          recommendation: rec,
          onTap: () {
            DfHaptics.light();
            context.push(AppRoutes.platformIntegrations);
          },
        );
      },
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.recommendation,
    required this.onTap,
  });

  final PlatformShiftRecommendation recommendation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return DfCard(
      variant: DfCardVariant.elevated,
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandBlue.withValues(alpha: 0.10),
            ),
            alignment: Alignment.center,
            child: PlatformBrandIcon(
              platform: recommendation.recommended,
              size: 28,
              borderRadius: 8,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Melhor app agora',
                  style: AppTypography.labelCaps(brightness),
                ),
                const SizedBox(height: 2),
                Text(
                  recommendation.recommended.label,
                  style: AppTypography.iosHeadline(brightness).copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.secondaryLabel(theme).withValues(alpha: 0.55),
          ),
        ],
      ),
    );
  }
}
