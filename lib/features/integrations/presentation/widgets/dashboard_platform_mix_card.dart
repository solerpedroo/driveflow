import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../analytics/presentation/widgets/platform_revenue_donut_chart.dart';
import '../providers/platform_analytics_providers.dart';

/// Card de mix de hoje no Dashboard.
class DashboardPlatformMixCard extends ConsumerWidget {
  const DashboardPlatformMixCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mix = ref.watch(platformTodayMixProvider);

    return mix.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (slices) {
        if (slices.isEmpty) return const SizedBox.shrink();
        return PlatformRevenueDonutChart(slices: slices);
      },
    );
  }
}
