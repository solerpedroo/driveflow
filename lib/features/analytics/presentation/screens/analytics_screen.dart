import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../goals/domain/entities/goal_entity.dart';
import '../../../vehicle/presentation/widgets/vehicle_scope_chip.dart';
import '../../domain/entities/analytics_enums.dart';
import '../providers/analytics_providers.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/period_comparison_bar_chart.dart';
import '../widgets/period_comparison_card.dart';
import '../widgets/profit_trend_chart.dart';

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
    final breakdownAsync = ref.watch(analyticsCategoryBreakdownProvider);
    final comparisonAsync = ref.watch(analyticsComparisonProvider);

    return Scaffold(
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
                child: Row(
                  children: TrendWindow.values.map((window) {
                    final selected = window == trendWindow;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(window.label),
                        selected: selected,
                        onSelected: (_) => ref
                            .read(analyticsTrendWindowProvider.notifier)
                            .state = window,
                      ),
                    );
                  }).toList(growable: false),
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
                child: Row(
                  children: GoalPeriod.values.map((item) {
                    final selected = item == period;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(item.label),
                        selected: selected,
                        onSelected: (_) => ref
                            .read(analyticsPeriodProvider.notifier)
                            .state = item,
                      ),
                    );
                  }).toList(growable: false),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            sliver: SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ComparisonReference.values.map((item) {
                    final selected = item == reference;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(item.label),
                        selected: selected,
                        onSelected: (_) => ref
                            .read(analyticsComparisonReferenceProvider.notifier)
                            .state = item,
                      ),
                    );
                  }).toList(growable: false),
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
