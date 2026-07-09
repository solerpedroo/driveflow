import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_section_header.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/driveflow_period_filter.dart';
import '../providers/earnings_providers.dart';
import '../widgets/earning_tile.dart';

/// Listagem de ganhos com filtros de período e plataforma.
class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final period = ref.watch(earningsPeriodProvider);
    final platformFilter = ref.watch(earningsPlatformFilterProvider);
    final earningsAsync = ref.watch(earningsListProvider);
    final totalAsync = ref.watch(earningsTotalProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(earningsRepositoryProvider).fetchEarnings();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: DfScreenTitle(
                title: 'Ganhos',
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DriveFlowPeriodFilter(
                      value: period,
                      onChanged: (p) =>
                          ref.read(earningsPeriodProvider.notifier).state = p,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('Todas'),
                            selected: platformFilter == null,
                            onSelected: (_) => ref
                                .read(earningsPlatformFilterProvider.notifier)
                                .state = null,
                          ),
                          ...kRidePlatforms.map(
                            (platform) => Padding(
                              padding:
                                  const EdgeInsets.only(left: AppSpacing.sm),
                              child: FilterChip(
                                label: Text(platform.label),
                                selected: platformFilter == platform,
                                onSelected: (_) => ref
                                    .read(
                                        earningsPlatformFilterProvider.notifier)
                                    .state = platform,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
                AppSpacing.screenHorizontal,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: DfCard(
                  child: Row(
                    children: [
                      const Icon(Icons.payments_outlined,
                          color: AppColors.profitGreen),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total no período',
                                style: theme.textTheme.labelMedium),
                            totalAsync.when(
                              loading: () => const Text('...'),
                              error: (e, _) => const Text('Erro'),
                              data: (total) => Text(
                                CurrencyFormatter.format(total),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: AppColors.profitGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            earningsAsync.when(
              loading: () => const SliverFillRemaining(child: DfSkeleton()),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Erro: $e')),
              ),
              data: (earnings) {
                if (earnings.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: DfEmptyState(
                      variant: DfEmptyStateVariant.illustrated,
                      icon: Icons.payments_outlined,
                      title: 'Nenhum ganho neste período',
                      subtitle:
                          'Toque em + Ganho para registrar sua primeira corrida.',
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    AppSpacing.lg,
                    AppSpacing.screenHorizontal,
                    96,
                  ),
                  sliver: SliverList.separated(
                    itemCount: earnings.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) =>
                        EarningTile(earning: earnings[index]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.earningForm),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ganho'),
      ),
    );
  }
}
