import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../analytics/presentation/widgets/expense_pie_chart.dart';
import '../../../analytics/presentation/widgets/period_comparison_card.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../../../vehicle/presentation/widgets/vehicle_scope_chip.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_goal_period_chips.dart';
import '../../../../shared/widgets/design_system/df_header_row.dart';
import '../../../../shared/widgets/design_system/df_hero_wealth_card.dart';
import '../../../../shared/widgets/design_system/df_quick_actions.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_tab_scroll_view.dart';
import '../../../analytics/presentation/providers/analytics_providers.dart';
import '../../domain/entities/report_snapshot.dart';
import '../providers/reports_providers.dart';
import '../widgets/report_indicators_card.dart';

/// Relatórios — mesmo DNA da Início / Ganhos / Despesas.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  static void _toggleVisibility(WidgetRef ref, bool hidden) {
    ref.read(valueVisibilityHiddenProvider.notifier).state = !hidden;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    final reportAsync = ref.watch(reportSnapshotProvider);
    final comparisonAsync = ref.watch(reportComparisonProvider);
    final breakdownAsync = ref.watch(reportCategoryBreakdownProvider);
    final hidden = ref.watch(valueVisibilityHiddenProvider);
    final exportState = ref.watch(reportsControllerProvider);

    return DfTabScrollView(
      onRefresh: () async {
        ref.invalidate(reportSnapshotProvider);
        ref.invalidate(reportComparisonProvider);
        ref.invalidate(reportCategoryBreakdownProvider);
      },
      children: [
        const DfHeaderRow(),
        const DfScreenTitleRow(title: 'Relatórios'),
        const Align(
          alignment: Alignment.centerLeft,
          child: VehicleScopeChip(),
        ),
        reportAsync.when(
          loading: () => const SizedBox(
            height: 140,
            child: DfSkeleton(itemCount: 1),
          ),
          error: (_, __) => Text(
            'Não foi possível carregar. Tente novamente.',
            style: AppTypography.iosBody(Theme.of(context).brightness).copyWith(
              color: AppColors.secondaryLabel(Theme.of(context)),
            ),
          ),
          data: (report) => _ReportsHero(
            report: report,
            hideValue: hidden,
            onToggleVisibility: () => _toggleVisibility(ref, hidden),
          ),
        ),
        DfQuickActions(
          actions: [
            DfQuickAction(
              icon: Icons.picture_as_pdf_rounded,
              label: 'PDF',
              onTap: exportState.isLoading
                  ? () {}
                  : () =>
                      ref.read(reportsControllerProvider.notifier).exportPdf(),
            ),
            DfQuickAction(
              icon: Icons.table_chart_rounded,
              label: 'CSV',
              onTap: exportState.isLoading
                  ? () {}
                  : () =>
                      ref.read(reportsControllerProvider.notifier).exportCsv(),
            ),
            DfQuickAction(
              icon: Icons.payments_rounded,
              label: 'Ganhos',
              onTap: () => context.go('${AppRoutes.home}?tab=earnings'),
            ),
            DfQuickAction(
              icon: Icons.receipt_long_rounded,
              label: 'Despesas',
              onTap: () => context.go('${AppRoutes.home}?tab=expenses'),
            ),
          ],
        ),
        if (exportState.hasError)
          Text(
            exportState.error.toString(),
            style: AppTypography.iosFootnote(Theme.of(context).brightness)
                .copyWith(color: Theme.of(context).colorScheme.error),
          ),
        _ReportsFiltersCard(
          period: period,
          onPeriodChanged: (p) =>
              ref.read(reportPeriodProvider.notifier).state = p,
        ),
        reportAsync.when(
          loading: () => const DfSkeleton(itemCount: 2),
          error: (_, __) => const SizedBox.shrink(),
          data: (report) => ReportIndicatorsCard(
            report: report,
            hideValue: hidden,
          ),
        ),
        comparisonAsync.when(
          loading: () => const DfSkeleton(itemCount: 2),
          error: (_, __) => Text(
            'Não foi possível carregar a comparação.',
            style: AppTypography.iosBody(Theme.of(context).brightness).copyWith(
              color: AppColors.secondaryLabel(Theme.of(context)),
            ),
          ),
          data: (comparison) => PeriodComparisonCard(
            comparison: comparison,
            hideValue: hidden,
          ),
        ),
        breakdownAsync.when(
          loading: () => const DfSkeleton(itemCount: 3),
          error: (_, __) => Text(
            'Não foi possível carregar a distribuição.',
            style: AppTypography.iosBody(Theme.of(context).brightness).copyWith(
              color: AppColors.secondaryLabel(Theme.of(context)),
            ),
          ),
          data: (slices) => ExpensePieChart(
            slices: slices,
            hideValue: hidden,
          ),
        ),
      ],
    );
  }
}

class _ReportsHero extends StatelessWidget {
  const _ReportsHero({
    required this.report,
    required this.hideValue,
    required this.onToggleVisibility,
  });

  final ReportSnapshot report;
  final bool hideValue;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final summary = report.summary;

    return DfHeroWealthCard(
      label: 'Lucro no período',
      value: CurrencyFormatter.formatSigned(summary.profit),
      badge: '${summary.rides} corridas',
      hideValue: hideValue,
      onToggleVisibility: onToggleVisibility,
      footer: Row(
        children: [
          Expanded(
            child: _HeroStat(
              label: 'Receita',
              value: hideValue
                  ? '•••'
                  : CurrencyFormatter.format(summary.revenue),
              brightness: brightness,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _HeroStat(
              label: 'Despesas',
              value: hideValue
                  ? '•••'
                  : CurrencyFormatter.format(summary.expenses),
              brightness: brightness,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.brightness,
  });

  final String label;
  final String value;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.iosFootnote(brightness).copyWith(
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.iosHeadline(brightness).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _ReportsFiltersCard extends StatelessWidget {
  const _ReportsFiltersCard({
    required this.period,
    required this.onPeriodChanged,
  });

  final GoalPeriod period;
  final ValueChanged<GoalPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return DfCard(
      variant: DfCardVariant.elevated,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros',
            style: AppTypography.labelCaps(brightness),
          ),
          const SizedBox(height: AppSpacing.md),
          DfGoalPeriodChips(
            selected: period,
            onChanged: onPeriodChanged,
          ),
        ],
      ),
    );
  }
}
