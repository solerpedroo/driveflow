import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_expandable_list_section.dart';
import '../../../../shared/widgets/design_system/df_filter_pill.dart';
import '../../../../shared/widgets/design_system/df_section_header.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';
import '../../../../shared/widgets/platform_brand_icon.dart';
import '../providers/platform_trips_providers.dart';
import '../widgets/platform_trip_tile.dart';

/// Histórico de corridas sincronizadas — layout Mescla.
class PlatformTripsScreen extends ConsumerWidget {
  const PlatformTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tripsAsync = ref.watch(platformTripsListProvider);
    final filter = ref.watch(platformTripsFilterProvider);
    final feeAsync = ref.watch(platformFeeAnalysisProvider);

    return DfSubpageScaffold(
      title: 'Histórico de corridas',
      onRefresh: () =>
          ref.read(platformTripsRepositoryProvider).fetchTrips(),
      children: [
        Text(
          'Corridas puxadas automaticamente dos apps conectados.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.secondaryLabel(theme),
            height: 1.45,
          ),
        ),
        feeAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (fees) {
            if (fees.isEmpty) return const SizedBox.shrink();
            final best = fees.first;
            return DfCard(
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
                    '${best.avgTakeRatePercent.toStringAsFixed(1)}% take rate',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryLabel(theme),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const DfSectionHeader(title: 'Filtro', eyebrow: 'Plataforma'),
        SingleChildScrollView(
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
                        leading: PlatformBrandIcon(
                          platform: platform,
                          size: 20,
                          borderRadius: 6,
                        ),
                        onSelected: () => ref
                            .read(platformTripsFilterProvider.notifier)
                            .state = platform,
                      ),
                    ),
                  ),
            ],
          ),
        ),
        tripsAsync.when(
          loading: () => const DfSkeleton(itemCount: 3),
          error: (e, _) => Text('Erro ao carregar corridas: $e'),
          data: (trips) {
            if (trips.isEmpty) {
              return DfCard(
                child: const DfEmptyState(
                  variant: DfEmptyStateVariant.illustrated,
                  icon: Icons.route_outlined,
                  title: 'Nenhuma corrida sincronizada',
                  subtitle:
                      'Conecte Uber, 99 ou InDrive e sincronize para ver o histórico aqui.',
                ),
              );
            }
            return DfExpandableListSection(
              title: 'Corridas recentes',
              eyebrow: 'Sync',
              itemCount: trips.length,
              itemBuilder: (context, index) =>
                  PlatformTripTile(trip: trips[index]),
            );
          },
        ),
      ],
    );
  }
}
