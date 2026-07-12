import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/date_range_period.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_expandable_list_section.dart';
import '../../../../shared/widgets/design_system/df_header_row.dart';
import '../../../../shared/widgets/design_system/df_hero_wealth_card.dart';
import '../../../../shared/widgets/design_system/df_quick_actions.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_tab_scroll_view.dart';
import '../../../../shared/widgets/driveflow_period_filter.dart';
import '../providers/expenses_providers.dart';
import '../widgets/expense_tile.dart';

/// Despesas — mesmo DNA da Início / Ganhos.
class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  static void _toggleVisibility(WidgetRef ref, bool hidden) {
    ref.read(valueVisibilityHiddenProvider.notifier).state = !hidden;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(expensesPeriodProvider);
    final groupedAsync = ref.watch(expensesGroupedProvider);
    final totalAsync = ref.watch(expensesTotalProvider);
    final hidden = ref.watch(valueVisibilityHiddenProvider);

    return groupedAsync.when(
      loading: () => const DfTabScrollView(
        children: [
          DfHeaderRow(),
          DfScreenTitleRow(title: 'Despesas'),
          DfSkeleton(itemCount: 4),
        ],
      ),
      error: (e, _) => DfTabScrollView(
        children: [
          const DfHeaderRow(),
          const DfScreenTitleRow(title: 'Despesas'),
          Text(
            'Não foi possível carregar. Tente novamente.',
            style: AppTypography.iosBody(Theme.of(context).brightness).copyWith(
              color: AppColors.secondaryLabel(Theme.of(context)),
            ),
          ),
        ],
      ),
      data: (grouped) {
        final categories = grouped.keys.toList()
          ..sort((a, b) => a.label.compareTo(b.label));
        final itemCount = grouped.values.fold<int>(
          0,
          (sum, items) => sum + items.length,
        );

        return DfTabScrollView(
          onRefresh: () async {
            await ref.read(expensesRepositoryProvider).fetchExpenses();
          },
          children: [
            const DfHeaderRow(),
            const DfScreenTitleRow(title: 'Despesas'),
            totalAsync.when(
              loading: () => const SizedBox(
                height: 140,
                child: DfSkeleton(itemCount: 1),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (total) => _ExpensesHero(
                total: total,
                itemCount: itemCount,
                categoryCount: categories.length,
                hideValue: hidden,
                onToggleVisibility: () => _toggleVisibility(ref, hidden),
              ),
            ),
            DfQuickActions(
              actions: [
                DfQuickAction(
                  icon: Icons.add_rounded,
                  label: 'Despesa',
                  onTap: () => context.push(AppRoutes.expenseForm),
                ),
                DfQuickAction(
                  icon: Icons.upload_file_rounded,
                  label: 'Importar',
                  onTap: () => context.push(AppRoutes.importStatement),
                ),
                DfQuickAction(
                  icon: Icons.local_gas_station_rounded,
                  label: 'Combustível',
                  onTap: () => context.push(AppRoutes.fuelHistory),
                ),
                DfQuickAction(
                  icon: Icons.build_circle_outlined,
                  label: 'Manutenção',
                  onTap: () => context.push(AppRoutes.maintenanceHistory),
                ),
              ],
            ),
            _ExpensesFiltersCard(
              period: period,
              onPeriodChanged: (p) =>
                  ref.read(expensesPeriodProvider.notifier).state = p,
            ),
            if (grouped.isEmpty)
              const DfEmptyState(
                variant: DfEmptyStateVariant.illustrated,
                icon: Icons.receipt_long_outlined,
                title: 'Nenhuma despesa neste período',
                subtitle:
                    'Registre combustível, pedágio e outros custos.',
              )
            else
              ...categories.map((category) {
                final items = grouped[category]!;
                return DfExpandableListSection(
                  title: category.label,
                  eyebrow: 'Categoria',
                  itemCount: items.length,
                  spacing: AppSpacing.md,
                  itemBuilder: (context, index) =>
                      ExpenseTile(expense: items[index], hideValue: hidden),
                  seeAllLabel: 'Ver todas',
                );
              }),
          ],
        );
      },
    );
  }
}

class _ExpensesHero extends StatelessWidget {
  const _ExpensesHero({
    required this.total,
    required this.itemCount,
    required this.categoryCount,
    required this.hideValue,
    required this.onToggleVisibility,
  });

  final double total;
  final int itemCount;
  final int categoryCount;
  final bool hideValue;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return DfHeroWealthCard(
      label: 'Total no período',
      value: CurrencyFormatter.format(total),
      badge: '$itemCount lançamentos',
      hideValue: hideValue,
      onToggleVisibility: onToggleVisibility,
      footer: Row(
        children: [
          Expanded(
            child: _HeroStat(
              label: 'Categorias',
              value: hideValue ? '•••' : '$categoryCount',
              brightness: brightness,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _HeroStat(
              label: 'Lançamentos',
              value: hideValue ? '•••' : '$itemCount',
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

class _ExpensesFiltersCard extends StatelessWidget {
  const _ExpensesFiltersCard({
    required this.period,
    required this.onPeriodChanged,
  });

  final DateRangePeriod period;
  final ValueChanged<DateRangePeriod> onPeriodChanged;

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
          DriveFlowPeriodFilter(
            value: period,
            onChanged: onPeriodChanged,
          ),
        ],
      ),
    );
  }
}
