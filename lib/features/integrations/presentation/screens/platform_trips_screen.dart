import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_filter_pill.dart';
import '../providers/platform_trips_providers.dart';
import 'platform_trip_tile.dart';

/// Histórico completo de corridas sincronizadas (Uber, 99, InDrive).
class PlatformTripsScreen extends ConsumerWidget {
  const PlatformTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tripsAsync = ref.watch(platformTripsListProvider);
    final filter = ref.watch(platformTripsFilterProvider);
    final feeAsync = ref.watch(platformFeeAnalysisProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Histórico de corridas'),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(platformTripsRepositoryProvider).fetchTrips(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Corridas puxadas automaticamente dos apps conectados. '
                  'Ganhos diários são calculados a partir deste histórico.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                    height: 1.45,
                  ),
                ),
              ),
            ),
            feeAsync.when(
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              data: (fees) {
                if (fees.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                final best = fees.first;
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: DfCard(
                      variant: DfCardVariant.hero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Menor taxa: ${best.platform.label}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${best.avgTakeRatePercent.toStringAsFixed(1)}% de take rate · '
                            '${CurrencyFormatter.format(best.avgPayoutPerTrip)}/corrida líquida',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.secondaryLabel(theme),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              sliver: SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      DfFilterPill(
                        label: 'Todas',
                        selected: filter == null,
                        onSelected: () => ref
                            .read(platformTripsFilterProvider.notifier)
                            .state = null,
                      ),
                      const SizedBox(width: 8),
                      ...RidePlatform.values
                          .where(
                            (p) =>
                                p == RidePlatform.uber ||
                                p == RidePlatform.ninetyNine ||
                                p == RidePlatform.inDrive,
                          )
                          .map(
                            (platform) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: DfFilterPill(
                                label: platform.label,
                                selected: filter == platform,
                                onSelected: () => ref
                                    .read(platformTripsFilterProvider.notifier)
                                    .state = platform,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
              sliver: tripsAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Text('Erro ao carregar corridas: $e'),
                ),
                data: (trips) {
                  if (trips.isEmpty) {
                    return SliverToBoxAdapter(
                      child: DfCard(
                        child: const DfEmptyState(
                          variant: DfEmptyStateVariant.illustrated,
                          icon: Icons.route_outlined,
                          title: 'Nenhuma corrida sincronizada',
                          subtitle:
                              'Conecte Uber, 99 ou InDrive e sincronize para ver o histórico aqui.',
                        ),
                      ),
                    );
                  }

                  return SliverList.separated(
                    itemCount: trips.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) =>
                        PlatformTripTile(trip: trips[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
