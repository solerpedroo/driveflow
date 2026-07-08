import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/driveflow_empty_state.dart';
import '../../../../shared/widgets/driveflow_glass_card.dart';
import '../../../../shared/widgets/driveflow_list_skeleton.dart';
import '../../../../shared/widgets/driveflow_period_filter.dart';
import '../../domain/entities/expense_entity.dart';
import '../providers/expenses_providers.dart';

/// Listagem de despesas agrupadas por categoria.
class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final period = ref.watch(expensesPeriodProvider);
    final groupedAsync = ref.watch(expensesGroupedProvider);
    final totalAsync = ref.watch(expensesTotalProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(expensesRepositoryProvider).fetchExpenses();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Despesas', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  DriveFlowPeriodFilter(
                    value: period,
                    onChanged: (p) =>
                        ref.read(expensesPeriodProvider.notifier).state = p,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            sliver: SliverToBoxAdapter(
              child: DriveFlowGlassCard(
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_outlined,
                        color: AppColors.expenseCoral),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total no período',
                              style: theme.textTheme.labelMedium),
                          totalAsync.when(
                            loading: () => const Text('...'),
                            error: (e, _) => const Text('Erro'),
                            data: (total) => Text(
                              CurrencyFormatter.format(total),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppColors.expenseCoral,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          groupedAsync.when(
            loading: () => const SliverFillRemaining(
              child: DriveFlowListSkeleton(),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Erro: $e')),
            ),
            data: (grouped) {
              if (grouped.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: DriveFlowEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Nenhuma despesa neste período',
                    subtitle: 'Registre combustível, pedágio e outros custos.',
                  ),
                );
              }

              final categories = grouped.keys.toList()
                ..sort((a, b) => a.label.compareTo(b.label));

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = categories[index];
                      final items = grouped[category]!;
                      final subtotal = items.fold<double>(
                        0,
                        (sum, e) => sum + e.amount,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(category.icon,
                                    size: 20, color: AppColors.expenseCoral),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    category.label,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(subtotal),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: AppColors.expenseCoral,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...items.map(
                              (expense) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _ExpenseTile(expense: expense),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: categories.length,
                  ),
                ),
              );
            },
          ),
        ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.expenseForm),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Despesa'),
      ),
    );
  }
}

class _ExpenseTile extends ConsumerWidget {
  const _ExpenseTile({required this.expense});

  final ExpenseEntity expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DriveFlowGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(AppRoutes.expenseForm, extra: expense),
        onLongPress: () => _confirmDelete(context, ref),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description?.isNotEmpty == true
                        ? expense.description!
                        : expense.category.label,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateUtilsDriveFlow.dayMonthYear.format(expense.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryLabel(theme),
                    ),
                  ),
                ],
              ),
            ),
            if (expense.receiptUrl != null)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.attach_file_rounded, size: 18),
              ),
            Text(
              CurrencyFormatter.format(expense.amount),
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.expenseCoral,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir despesa?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(expensesControllerProvider.notifier).delete(expense.id);
    }
  }
}
