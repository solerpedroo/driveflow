import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/expense_entity.dart';
import '../providers/expenses_providers.dart';

/// Tile de despesa na listagem.
class ExpenseTile extends ConsumerWidget {
  const ExpenseTile({required this.expense, super.key});

  final ExpenseEntity expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DfCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: () => context.push(AppRoutes.expenseForm, extra: expense),
        onLongPress: () => _confirmDelete(context, ref),
        child: Row(
          children: [
            Icon(expense.category.icon,
                size: 20, color: AppColors.expenseCoral),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description?.isNotEmpty == true
                        ? expense.description!
                        : expense.category.label,
                    style: theme.textTheme.bodyLarge,
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
