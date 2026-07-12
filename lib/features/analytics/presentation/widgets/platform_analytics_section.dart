import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../integrations/presentation/providers/platform_analytics_providers.dart';
import 'platform_efficiency_chart.dart';
import 'platform_net_profit_chart.dart';
import 'platform_revenue_chart.dart';
import 'platform_revenue_trend_chart.dart';
import 'platform_take_rate_trend_chart.dart';
import '../../../../shared/widgets/design_system/df_period_pill_chip.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../providers/analytics_providers.dart';

/// Seção completa de analytics por plataforma (ondas 30–33).
class PlatformAnalyticsSection extends ConsumerWidget {
  const PlatformAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final breakdown = ref.watch(analyticsPlatformBreakdownProvider);
    final trendWindow = ref.watch(platformTrendWindowProvider);
    final trend = ref.watch(platformRevenueTrendProvider);
    final deltas = ref.watch(platformTrendDeltaProvider);
    final netProfit = ref.watch(platformNetProfitProvider);
    final efficiency = ref.watch(platformEfficiencyProvider);
    final takeRate = ref.watch(platformTakeRateTrendProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Receita por app',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        breakdown.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (slices) {
            if (slices.isEmpty) return const SizedBox.shrink();
            return PlatformRevenueChart(slices: slices);
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Evolução por app',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        DfPeriodPillRow<PlatformTrendWindow>(
          segments: PlatformTrendWindow.values,
          selected: trendWindow,
          labelBuilder: (w) => w.label,
          onChanged: (w) =>
              ref.read(platformTrendWindowProvider.notifier).state = w,
        ),
        const SizedBox(height: 12),
        trend.when(
          loading: () => const DfSkeleton(itemCount: 2),
          error: (e, _) => Text('Não foi possível carregar. Tente novamente.'),
          data: (points) => PlatformRevenueTrendChart(
            points: points,
            deltas: deltas,
          ),
        ),
        const SizedBox(height: 24),
        netProfit.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (slices) {
            if (slices.isEmpty) return const SizedBox.shrink();
            return PlatformNetProfitChart(slices: slices);
          },
        ),
        const SizedBox(height: 16),
        efficiency.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (snapshots) {
            if (snapshots.isEmpty) return const SizedBox.shrink();
            return PlatformEfficiencyChart(snapshots: snapshots);
          },
        ),
        const SizedBox(height: 16),
        takeRate.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (points) {
            if (points.isEmpty) return const SizedBox.shrink();
            return PlatformTakeRateTrendChart(points: points);
          },
        ),
      ],
    );
  }
}
