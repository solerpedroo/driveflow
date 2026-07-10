import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../analytics/presentation/widgets/expense_pie_chart.dart';
import '../../../analytics/presentation/widgets/period_comparison_card.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../../../vehicle/presentation/widgets/vehicle_scope_chip.dart';
import '../../../../shared/widgets/design_system/df_header_row.dart';
import '../../../../shared/widgets/design_system/df_segmented_control.dart';
import '../../../../shared/widgets/design_system/df_tab_scroll_view.dart';
import '../../../analytics/presentation/providers/analytics_providers.dart';
import '../providers/reports_providers.dart';
import '../widgets/report_export_actions.dart';
import '../widgets/report_indicators_card.dart';

/// Relatórios no padrão Mescla — logo, período, indicadores, gráficos.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    final reportAsync = ref.watch(reportSnapshotProvider);
    final comparisonAsync = ref.watch(reportComparisonProvider);
    final breakdownAsync = ref.watch(reportCategoryBreakdownProvider);

    return DfTabScrollView(
      children: [
        const DfHeaderRow(),
        Text(
          'Relatórios',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const Align(
          alignment: Alignment.centerLeft,
          child: VehicleScopeChip(),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DfSegmentedControl<GoalPeriod>(
            segments: GoalPeriod.values,
            selected: period,
            labelBuilder: (p) => p.label,
            onChanged: (p) =>
                ref.read(reportPeriodProvider.notifier).state = p,
          ),
        ),
        reportAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Erro: $e'),
          data: (report) => ReportIndicatorsCard(report: report),
        ),
        comparisonAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Erro: $e'),
          data: (comparison) => PeriodComparisonCard(comparison: comparison),
        ),
        breakdownAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Erro: $e'),
          data: (slices) => ExpensePieChart(slices: slices),
        ),
        const ReportExportActions(),
      ],
    );
  }
}
