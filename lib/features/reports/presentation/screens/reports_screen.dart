import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../analytics/presentation/widgets/expense_pie_chart.dart';
import '../../../analytics/presentation/widgets/period_comparison_card.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../../../vehicle/presentation/widgets/vehicle_scope_chip.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_section_header.dart';
import '../providers/reports_providers.dart';
import '../widgets/report_export_actions.dart';
import '../widgets/report_indicators_card.dart';

/// Aba Relatórios — indicadores por período e exportação PDF/CSV.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    final reportAsync = ref.watch(reportSnapshotProvider);
    final comparisonAsync = ref.watch(reportComparisonProvider);
    final breakdownAsync = ref.watch(reportCategoryBreakdownProvider);

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: DfScreenTitle(title: 'Relatórios'),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.md,
            AppSpacing.screenHorizontal,
            0,
          ),
          sliver: const SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.centerLeft,
              child: VehicleScopeChip(),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
            AppSpacing.screenHorizontal,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: GoalPeriod.values.map((item) {
                  final selected = item == period;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      label: Text(item.label),
                      selected: selected,
                      selectedColor:
                          AppColors.electricTeal.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.electricTeal,
                      onSelected: (_) =>
                          ref.read(reportPeriodProvider.notifier).state = item,
                    ),
                  );
                }).toList(growable: false),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
            AppSpacing.screenHorizontal,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: reportAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erro: $e'),
              data: (report) => ReportIndicatorsCard(report: report),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
            AppSpacing.screenHorizontal,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: comparisonAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erro: $e'),
              data: (comparison) => PeriodComparisonCard(comparison: comparison),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
            AppSpacing.screenHorizontal,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: breakdownAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erro: $e'),
              data: (slices) => ExpensePieChart(slices: slices),
            ),
          ),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.xl,
            AppSpacing.screenHorizontal,
            AppSpacing.xxl,
          ),
          sliver: SliverToBoxAdapter(child: ReportExportActions()),
        ),
      ],
    );
  }
}
