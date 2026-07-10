import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../vehicle/presentation/widgets/vehicle_scope_chip.dart';
import '../../domain/entities/analytics_enums.dart';
import '../../../ai/presentation/providers/ai_providers.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../providers/analytics_providers.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/period_comparison_bar_chart.dart';
import '../widgets/period_comparison_card.dart';
import '../widgets/platform_analytics_section.dart';
import '../widgets/profit_forecast_card.dart';
import '../widgets/profit_trend_chart.dart';
import '../../../../shared/widgets/design_system/df_hero_wealth_card.dart';
import '../../../../shared/widgets/design_system/df_section_header.dart';
import '../../../../shared/widgets/design_system/df_goal_period_chips.dart';
import '../../../../shared/widgets/design_system/df_period_pill_chip.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';

/// Análises avançadas — layout Mescla com hero e seções.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendWindow = ref.watch(analyticsTrendWindowProvider);
    final period = ref.watch(analyticsPeriodProvider);
    final reference = ref.watch(analyticsComparisonReferenceProvider);
    final hidden = ref.watch(valueVisibilityHiddenProvider);

    final trendAsync = ref.watch(analyticsProfitTrendProvider);
    final forecastAsync = ref.watch(analyticsProfitForecastProvider);
    final aiForecastAsync = ref.watch(aiForecastControllerProvider);
    final breakdownAsync = ref.watch(analyticsCategoryBreakdownProvider);
    final comparisonAsync = ref.watch(analyticsComparisonProvider);
    final monthAsync = ref.watch(dashboardMonthProvider);

    return DfSubpageScaffold(
      title: 'Análises',
      valueHidden: hidden,
      onToggleValueVisibility: () => ref
          .read(valueVisibilityHiddenProvider.notifier)
          .state = !hidden,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: VehicleScopeChip(),
        ),
        monthAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (month) => DfHeroWealthCard(
            label: 'Lucro do mês',
            value: CurrencyFormatter.formatSigned(month.profit),
            badge: 'Referência atual',
            hideValue: hidden,
          ),
        ),
        const DfSectionHeader(title: 'Tendência de lucro', eyebrow: 'Gráfico'),
        DfPeriodPillRow<TrendWindow>(
          segments: TrendWindow.values,
          selected: trendWindow,
          labelBuilder: (w) => w.label,
          onChanged: (w) =>
              ref.read(analyticsTrendWindowProvider.notifier).state = w,
        ),
        trendAsync.when(
          loading: () => const DfSkeleton(itemCount: 3),
          error: (e, _) => Text('Erro: $e'),
          data: (points) => ProfitTrendChart(
            points: points,
            windowLabel: trendWindow.label,
          ),
        ),
        forecastAsync.when(
          loading: () => const DfSkeleton(itemCount: 3),
          error: (e, _) => Text('Erro: $e'),
          data: (forecast) => ProfitForecastCard(
            forecast: forecast,
            aiSummary: aiForecastAsync.valueOrNull?.summary,
            isLoadingAi: aiForecastAsync.isLoading,
            onRequestAi: () =>
                ref.read(aiForecastControllerProvider.notifier).generate(),
          ),
        ),
        const DfSectionHeader(title: 'Comparar períodos', eyebrow: 'Análise'),
        DfGoalPeriodChips(
          selected: period,
          onChanged: (p) =>
              ref.read(analyticsPeriodProvider.notifier).state = p,
        ),
        DfPeriodPillRow<ComparisonReference>(
          segments: ComparisonReference.values,
          selected: reference,
          labelBuilder: (r) => r.label,
          onChanged: (r) => ref
              .read(analyticsComparisonReferenceProvider.notifier)
              .state = r,
        ),
        comparisonAsync.when(
          loading: () => const DfSkeleton(itemCount: 3),
          error: (e, _) => Text('Erro: $e'),
          data: (comparison) => Column(
            children: [
              PeriodComparisonCard(comparison: comparison),
              const SizedBox(height: 16),
              PeriodComparisonBarChart(comparison: comparison),
            ],
          ),
        ),
        const PlatformAnalyticsSection(),
        const DfSectionHeader(
          title: 'Distribuição de despesas',
          eyebrow: 'Categorias',
        ),
        breakdownAsync.when(
          loading: () => const DfSkeleton(itemCount: 3),
          error: (e, _) => Text('Erro: $e'),
          data: (slices) => ExpensePieChart(slices: slices),
        ),
      ],
    );
  }
}
