import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../vehicle/presentation/widgets/vehicle_scope_chip.dart';
import '../../domain/entities/analytics_enums.dart';
import '../../../ai/presentation/providers/ai_providers.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../providers/analytics_providers.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/period_comparison_bar_chart.dart';
import '../widgets/period_comparison_card.dart';
import '../widgets/profit_forecast_card.dart';
import '../widgets/profit_trend_chart.dart';
import '../../../../shared/widgets/design_system/df_segmented_control.dart';

/// Tela de análises avançadas — tendências, pizza e comparação de períodos.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final trendWindow = ref.watch(analyticsTrendWindowProvider);
    final period = ref.watch(analyticsPeriodProvider);
    final reference = ref.watch(analyticsComparisonReferenceProvider);

    final trendAsync = ref.watch(analyticsProfitTrendProvider);
    final forecastAsync = ref.watch(analyticsProfitForecastProvider);
    final aiForecastAsync = ref.watch(aiForecastControllerProvider);
    final breakdownAsync = ref.watch(analyticsCategoryBreakdownProvider);
    final comparisonAsync = ref.watch(analyticsComparisonProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Análises'),
        backgroundColor: Colors.transparent,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            sliver: SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.centerLeft,
                child: VehicleScopeChip(),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            sliver: SliverToBoxAdapter(
              child: Text('Tendência', style: theme.textTheme.titleMedium),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            sliver: SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DfSegmentedControl<TrendWindow>(
                  segments: TrendWindow.values,
                  selected: trendWindow,
                  labelBuilder: (w) => w.label,
                  onChanged: (w) =>
                      ref.read(analyticsTrendWindowProvider.notifier).state = w,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            sliver: SliverToBoxAdapter(
              child: trendAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erro: $e'),
                data: (points) => ProfitTrendChart(
                  points: points,
                  windowLabel: trendWindow.label,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            sliver: SliverToBoxAdapter(
              child: forecastAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erro: $e'),
                data: (forecast) => ProfitForecastCard(
                  forecast: forecast,
                  aiSummary: aiForecastAsync.valueOrNull?.summary,
                  isLoadingAi: aiForecastAsync.isLoading,
                  onRequestAi: () => ref
                      .read(aiForecastControllerProvider.notifier)
                      .generate(),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            sliver: SliverToBoxAdapter(
              child: Text('Comparar períodos', style: theme.textTheme.titleMedium),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            sliver: SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DfSegmentedControl<GoalPeriod>(
                  segments: GoalPeriod.values,
                  selected: period,
                  labelBuilder: (p) => p.label,
                  onChanged: (p) =>
                      ref.read(analyticsPeriodProvider.notifier).state = p,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            sliver: SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DfSegmentedControl<ComparisonReference>(
                  segments: ComparisonReference.values,
                  selected: reference,
                  labelBuilder: (r) => r.label,
                  onChanged: (r) => ref
                      .read(analyticsComparisonReferenceProvider.notifier)
                      .state = r,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            sliver: SliverToBoxAdapter(
              child: comparisonAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erro: $e'),
                data: (comparison) => Column(
                  children: [
                    PeriodComparisonCard(comparison: comparison),
                    const SizedBox(height: 16),
                    PeriodComparisonBarChart(comparison: comparison),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            sliver: SliverToBoxAdapter(
              child: Text('Distribuição de despesas',
                  style: theme.textTheme.titleMedium),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            sliver: SliverToBoxAdapter(
              child: breakdownAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erro: $e'),
                data: (slices) => ExpensePieChart(slices: slices),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
