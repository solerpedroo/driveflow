import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../../../vehicle/presentation/widgets/vehicle_scope_chip.dart';
import '../../../../shared/widgets/driveflow_glass_card.dart';
import '../providers/reports_providers.dart';

/// Aba Relatórios — indicadores por período e exportação PDF/CSV.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final period = ref.watch(reportPeriodProvider);
    final reportAsync = ref.watch(reportSnapshotProvider);
    final exportState = ref.watch(reportsControllerProvider);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: SliverToBoxAdapter(
            child: Text('Relatórios', style: theme.textTheme.headlineSmall),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
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
                      selectedColor: AppColors.electricTeal.withValues(alpha: 0.2),
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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: SliverToBoxAdapter(
            child: reportAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erro: $e'),
              data: (report) {
                final summary = report.summary;
                final profitColor = summary.profit >= 0
                    ? AppColors.profitGreen
                    : AppColors.expenseCoral;

                return DriveFlowGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Indicadores — ${report.periodLabel}',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _IndicatorRow(
                        label: 'Receita',
                        value: CurrencyFormatter.format(summary.revenue),
                      ),
                      _IndicatorRow(
                        label: 'Despesas',
                        value: CurrencyFormatter.format(summary.expenses),
                      ),
                      _IndicatorRow(
                        label: 'Lucro',
                        value: CurrencyFormatter.formatSigned(summary.profit),
                        valueColor: profitColor,
                      ),
                      _IndicatorRow(
                        label: 'Horas',
                        value: DurationFormatter.formatWorkedHours(
                          summary.workedHours,
                        ),
                      ),
                      _IndicatorRow(
                        label: 'Corridas',
                        value: '${summary.rides}',
                      ),
                      _IndicatorRow(
                        label: 'Km estimados',
                        value: summary.kmDriven > 0
                            ? summary.kmDriven.toStringAsFixed(0)
                            : '—',
                      ),
                      _IndicatorRow(
                        label: 'Combustível',
                        value: CurrencyFormatter.format(summary.fuelExpense),
                      ),
                      if (summary.profitPerHour != null)
                        _IndicatorRow(
                          label: 'Lucro / hora',
                          value: CurrencyFormatter.format(summary.profitPerHour!),
                        ),
                      if (summary.profitPerKm != null)
                        _IndicatorRow(
                          label: 'Lucro / km',
                          value: CurrencyFormatter.format(summary.profitPerKm!),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: exportState.isLoading
                      ? null
                      : () => ref
                          .read(reportsControllerProvider.notifier)
                          .exportPdf(),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Exportar PDF'),
                ),
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  onPressed: exportState.isLoading
                      ? null
                      : () => ref
                          .read(reportsControllerProvider.notifier)
                          .exportCsv(),
                  icon: const Icon(Icons.table_chart_outlined),
                  label: const Text('Exportar CSV'),
                ),
                if (exportState.hasError) ...[
                  const SizedBox(height: 12),
                  Text(
                    exportState.error.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IndicatorRow extends StatelessWidget {
  const _IndicatorRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryLabel(theme),
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
