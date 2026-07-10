import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../providers/platform_trips_providers.dart';
import 'platform_trip_tile.dart';

/// Preview das últimas corridas sincronizadas no hub de integrações.
class PlatformRecentTripsCard extends ConsumerWidget {
  const PlatformRecentTripsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tripsAsync = ref.watch(platformRecentTripsProvider);

    return tripsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (trips) {
        if (trips.isEmpty) return const SizedBox.shrink();

        return DfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Últimas corridas sincronizadas',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  DfButton(
                    label: 'Ver tudo',
                    variant: DfButtonVariant.tonal,
                    onPressed: () =>
                        context.push(AppRoutes.platformTripHistory),
                    expand: false,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ...trips.map(
                (trip) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PlatformTripTile(trip: trip),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
