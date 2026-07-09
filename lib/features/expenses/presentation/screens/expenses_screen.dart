import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_section_header.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/driveflow_period_filter.dart';
import '../../domain/entities/expense_entity.dart';
import '../providers/expenses_providers.dart';
import '../widgets/expense_tile.dart';

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
            SliverToBoxAdapter(
              child: DfScreenTitle(
                title: 'Despesas',
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DriveFlowPeriodFilter(
                      value: period,
                      onChanged: (p) =>
                          ref.read(expensesPeriodProvider.notifier).state = p,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DfButton(
                      label: 'Importar extrato',
                      icon: Icons.upload_file_outlined,
                      variant: DfButtonVariant.outlined,
                      onPressed: () => context.push(AppRoutes.importStatement),
                    ),
                  ],
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
                child: DfCard(
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long_outlined,
                          color: AppColors.expenseCoral),
                      const SizedBox(width: AppSpacing.md),
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
              loading: () => const SliverFillRemaining(child: DfSkeleton()),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Erro: $e')),
              ),
              data: (grouped) {
                if (grouped.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: DfEmptyState(
                      variant: DfEmptyStateVariant.illustrated,
                      icon: Icons.receipt_long_outlined,
                      title: 'Nenhuma despesa neste período',
                      subtitle:
                          'Registre combustível, pedágio e outros custos.',
                    ),
                  );
                }

                final categories = grouped.keys.toList()
                  ..sort((a, b) => a.label.compareTo(b.label));

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    AppSpacing.lg,
                    AppSpacing.screenHorizontal,
                    96,
                  ),
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
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(category.icon,
                                      size: 20,
                                      color: AppColors.expenseCoral),
                                  const SizedBox(width: AppSpacing.sm),
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
                              const SizedBox(height: AppSpacing.sm),
                              ...items.map(
                                (expense) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: AppSpacing.sm),
                                  child: ExpenseTile(expense: expense),
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
