import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../integrations/domain/entities/platform_consistency_snapshot.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../providers/platform_analytics_providers.dart';

/// Score de consistência de lucro diário por app.
class PlatformConsistencyCard extends ConsumerWidget {
  const PlatformConsistencyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final consistency = ref.watch(platformConsistencyProvider);

    return consistency.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();

        return DfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consistência por app',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final snap in data) _ConsistencyRow(snapshot: snap),
            ],
          ),
        );
      },
    );
  }
}

class _ConsistencyRow extends StatelessWidget {
  const _ConsistencyRow({required this.snapshot});

  final PlatformConsistencySnapshot snapshot;

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
                  snapshot.platform.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Média ${CurrencyFormatter.format(snapshot.avgDailyProfit)}/dia · '
                  '${snapshot.activeDays} dias ativos',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (snapshot.isStable
                      ? AppColors.profitGreen
                      : AppColors.warningAmber)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${snapshot.consistencyScore.round()}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: snapshot.isStable
                    ? AppColors.profitGreen
                    : AppColors.warningAmber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
