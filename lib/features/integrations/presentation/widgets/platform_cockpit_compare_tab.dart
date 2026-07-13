import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../providers/platform_trips_providers.dart';
import 'platform_consistency_card.dart';
import 'platform_performance_comparison_card.dart';
import 'platform_region_card.dart';

/// Aba Comparativo — performance, regiões e consistência.
class PlatformCockpitCompareTab extends ConsumerWidget {
  const PlatformCockpitCompareTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PlatformPerformanceComparisonCard(),
        const SizedBox(height: AppSpacing.md),
        const PlatformRegionCard(),
        const SizedBox(height: AppSpacing.md),
        const PlatformConsistencyCard(),
        ref.watch(platformFeeAnalysisProvider).when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (fees) {
            if (fees.isEmpty) return const SizedBox.shrink();
            final best = fees.first;
            return DfCard(
              child: Text(
                'Menor taxa: ${best.platform.label} '
                '(${best.avgTakeRatePercent.toStringAsFixed(1)}%)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryLabel(theme),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
