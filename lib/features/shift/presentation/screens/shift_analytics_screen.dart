import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_filter_pill.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';
import '../../domain/entities/shift_analytics_period.dart';
import '../providers/shift_analytics_providers.dart';
import '../providers/shift_history_providers.dart';
import '../widgets/shift_adherence_trend_chart.dart';
import '../widgets/shift_analytics_kpi_grid.dart';
import '../widgets/shift_period_comparison_card.dart';
import '../widgets/shift_platform_mix_chart.dart';
import '../widgets/shift_revenue_trend_chart.dart';

/// Dashboard analítico dos turnos encerrados.
class ShiftAnalyticsScreen extends ConsumerWidget {
  const ShiftAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(shiftAnalyticsPeriodProvider);
    final historyAsync = ref.watch(shiftHistoryStreamProvider);
    final summary = ref.watch(shiftAnalyticsSummaryProvider);
    final hidden = ref.watch(valueVisibilityHiddenProvider);

    return DfSubpageScaffold(
      title: 'Analytics de turnos',
      onRefresh: () async {
        await ref.read(shiftHistoryRepositoryProvider).fetchHistory();
      },
      children: [
        Row(
          children: [
            for (final option in ShiftAnalyticsPeriod.values) ...[
              DfFilterPill(
                label: option.label,
                selected: period == option,
                onSelected: () => ref
                    .read(shiftAnalyticsPeriodProvider.notifier)
                    .state = option,
              ),
              if (option != ShiftAnalyticsPeriod.values.last)
                const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        historyAsync.when(
          loading: () => const DfSkeleton(itemCount: 5),
          error: (_, __) => const DfEmptyState(
            icon: Icons.bar_chart_rounded,
            title: 'Não foi possível carregar',
            subtitle: 'Puxe para atualizar.',
          ),
          data: (_) {
            if (summary.isEmpty) {
              return DfEmptyState(
                variant: DfEmptyStateVariant.illustrated,
                icon: Icons.bar_chart_rounded,
                title: 'Sem turnos no período',
                subtitle:
                    'Encerre turnos no Modo turno para ver tendências aqui.',
                actionLabel: 'Iniciar turno',
                onAction: () => context.push(AppRoutes.shiftMode),
              );
            }

            return Column(
              children: [
                ShiftAnalyticsKpiGrid(
                  summary: summary,
                  hideValues: hidden,
                ),
                const SizedBox(height: AppSpacing.md),
                ShiftRevenueTrendChart(
                  points: summary.dailyPoints,
                  windowLabel: period.label,
                ),
                const SizedBox(height: AppSpacing.md),
                ShiftAdherenceTrendChart(points: summary.dailyPoints),
                const SizedBox(height: AppSpacing.md),
                ShiftPlatformMixChart(
                  platformRevenue: summary.platformRevenue,
                ),
                if (summary.comparison != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  ShiftPeriodComparisonCard(
                    comparison: summary.comparison!,
                    periodLabel: period.label,
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
