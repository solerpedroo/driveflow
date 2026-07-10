import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../analytics/presentation/providers/analytics_providers.dart';
import 'platform_revenue_chart.dart';

/// Seção de analytics por plataforma na tela de Análises.
class PlatformAnalyticsSection extends ConsumerWidget {
  const PlatformAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final breakdown = ref.watch(analyticsPlatformBreakdownProvider);

    return breakdown.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (slices) {
        if (slices.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receita por app',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            PlatformRevenueChart(slices: slices),
          ],
        );
      },
    );
  }
}
