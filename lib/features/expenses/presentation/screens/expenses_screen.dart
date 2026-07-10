import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_expandable_list_section.dart';
import '../../../../shared/widgets/design_system/df_header_row.dart';
import '../../../../shared/widgets/design_system/df_hero_wealth_card.dart';
import '../../../../shared/widgets/design_system/df_pill_action_button.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_tab_scroll_view.dart';
import '../../../../shared/widgets/driveflow_period_filter.dart';
import '../providers/expenses_providers.dart';
import '../widgets/expense_tile.dart';

/// Despesas no padrão Mescla Carteira — hero, ações 2×2, categorias.
class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(expensesPeriodProvider);
    final groupedAsync = ref.watch(expensesGroupedProvider);
    final totalAsync = ref.watch(expensesTotalProvider);
    final hidden = ref.watch(valueVisibilityHiddenProvider);

    return groupedAsync.when(
      loading: () => const Center(child: DfSkeleton(itemCount: 4)),
      error: (e, _) => Center(child: Text('Erro: $e')),
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
              DfScreenTitleRow(
                title: 'Despesas',
                hidden: hidden,
                onToggleVisibility: () => ref
                    .read(valueVisibilityHiddenProvider.notifier)
                    .state = !hidden,
              ),
              totalAsync.when(
                loading: () => const SizedBox(
                  height: 140,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (total) => DfHeroWealthCard(
                  label: 'Total no período',
                  value: CurrencyFormatter.format(total),
                  badge: '$itemCount lançamentos',
                  hideValue: hidden,
                ),
              ),
              DfPillActionGrid(
                actions: [
                  DfPillActionButton(
                    icon: Icons.add_circle_outline,
                    label: 'Nova despesa',
                    onTap: () => context.push(AppRoutes.expenseForm),
                  ),
                  DfPillActionButton(
                    icon: Icons.upload_file_outlined,
                    label: 'Importar',
                    onTap: () => context.push(AppRoutes.importStatement),
                  ),
                  DfPillActionButton(
                    icon: Icons.local_gas_station_outlined,
                    label: 'Combustível',
                    onTap: () => context.push(AppRoutes.fuelHistory),
                  ),
                  DfPillActionButton(
                    icon: Icons.build_circle_outlined,
                    label: 'Manutenção',
                    onTap: () => context.push(AppRoutes.maintenanceHistory),
                  ),
                ],
              ),
              DriveFlowPeriodFilter(
                value: period,
                onChanged: (p) =>
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
