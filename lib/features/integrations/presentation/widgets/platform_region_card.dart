import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../integrations/domain/entities/platform_region_snapshot.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../providers/platform_analytics_providers.dart';

/// Top regiões por R$/corrida por app.
class PlatformRegionCard extends ConsumerWidget {
  const PlatformRegionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final regions = ref.watch(platformRegionTopProvider);

    return regions.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();

        return DfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Melhores regiões',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final region in data.take(5)) _RegionRow(region: region),
            ],
          ),
        );
      },
    );
  }
}

class _RegionRow extends StatelessWidget {
  const _RegionRow({required this.region});

  final PlatformRegionSnapshot region;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  region.regionLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${region.platform.label} · ${region.tripCount} corridas',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(region.avgPayout),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.profitGreen,
            ),
          ),
        ],
      ),
    );
  }
}
