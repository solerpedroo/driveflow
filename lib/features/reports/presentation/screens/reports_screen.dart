import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../analytics/presentation/widgets/expense_pie_chart.dart';
import '../../../analytics/presentation/widgets/period_comparison_card.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../../../vehicle/presentation/widgets/vehicle_scope_chip.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/widgets/design_system/df_goal_period_chips.dart';
import '../../../../shared/widgets/design_system/df_header_row.dart';
import '../../../../shared/widgets/design_system/df_hero_wealth_card.dart';
import '../../../../shared/widgets/design_system/df_section_header.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_tab_scroll_view.dart';
import '../providers/reports_providers.dart';
import '../widgets/report_export_actions.dart';
import '../widgets/report_indicators_card.dart';

/// Relatórios no padrão Mescla — hero, período, indicadores, gráficos.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    final reportAsync = ref.watch(reportSnapshotProvider);
    final comparisonAsync = ref.watch(reportComparisonProvider);
    final breakdownAsync = ref.watch(reportCategoryBreakdownProvider);
    final hidden = ref.watch(valueVisibilityHiddenProvider);

    return DfTabScrollView(
      children: [
        const DfHeaderRow(),
        DfScreenTitleRow(
          title: 'Relatórios',
          hidden: hidden,
          onToggleVisibility: () => ref
              .read(valueVisibilityHiddenProvider.notifier)
              .state = !hidden,
        ),
        const Align(
          alignment: Alignment.centerLeft,
          child: VehicleScopeChip(),
        ),
        DfGoalPeriodChips(
          selected: period,
          onChanged: (p) =>
              ref.read(reportPeriodProvider.notifier).state = p,
        ),
        reportAsync.when(
          loading: () => const DfSkeleton(itemCount: 1),
          error: (e, _) => Text('Erro: $e'),
          data: (report) => DfHeroWealthCard(
            label: 'Lucro no período',
            value: CurrencyFormatter.formatSigned(report.summary.profit),
            badge: '${report.summary.rides} corridas',
            hideValue: hidden,
          ),
        ),
        reportAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (report) => ReportIndicatorsCard(report: report),
        ),
        const DfSectionHeader(title: 'Comparação', eyebrow: 'Período'),
        comparisonAsync.when(
          loading: () => const DfSkeleton(itemCount: 2),
          error: (e, _) => Text('Erro: $e'),
          data: (comparison) => PeriodComparisonCard(comparison: comparison),
        ),
        const DfSectionHeader(
          title: 'Distribuição de despesas',
          eyebrow: 'Categorias',
        ),
        breakdownAsync.when(
          loading: () => const DfSkeleton(itemCount: 3),
          error: (e, _) => Text('Erro: $e'),
          data: (slices) => ExpensePieChart(slices: slices),
        ),
        const ReportExportActions(),
      ],
    );
  }
}
