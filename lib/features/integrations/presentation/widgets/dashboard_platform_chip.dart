import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/platform_shift_recommendation.dart';
import '../providers/integrations_providers.dart';

/// Chip no dashboard — melhor app para rodar agora.
class DashboardPlatformChip extends ConsumerWidget {
  const DashboardPlatformChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recommendation = ref.watch(platformShiftRecommendationProvider);

    return recommendation.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (rec) {
        if (rec == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: _ChipContent(
            recommendation: rec,
            onTap: () => context.push(AppRoutes.platformIntegrations),
            theme: theme,
          ),
        );
      },
    );
  }
}

class _ChipContent extends StatelessWidget {
  const _ChipContent({
    required this.recommendation,
    required this.onTap,
    required this.theme,
  });

  final PlatformShiftRecommendation recommendation;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.profitGreen.withValues(alpha: 0.18),
                AppColors.skyBlue.withValues(alpha: 0.12),
              ],
            ),
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: AppColors.profitGreen.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.hub_rounded, color: AppColors.profitGreen, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Melhor app agora: ${recommendation.recommended.label}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.secondaryLabel(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
