import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/design_system/df_confirm_dialog.dart';
import '../../../../shared/widgets/design_system/df_movimentacao_tile.dart';
import '../../domain/entities/expense_entity.dart';
import '../providers/expenses_providers.dart';

/// Tile de despesa — padrão Mescla movimentação.
class ExpenseTile extends ConsumerWidget {
  const ExpenseTile({
    required this.expense,
    super.key,
    this.hideValue = false,
  });

  final ExpenseEntity expense;
  final bool hideValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = expense.description?.isNotEmpty == true
        ? expense.description!
        : expense.category.label;

    return DfMovimentacaoTile(
      title: title,
      detailCaps: expense.category.label,
      dateLabel: DateUtilsDriveFlow.dayMonthYear.format(expense.date),
      amount: CurrencyFormatter.format(expense.amount),
      isCredit: false,
      hideValue: hideValue,
      onTap: () => context.push(AppRoutes.expenseForm, extra: expense),
      onLongPress: () => _confirmDelete(context, ref),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await DfConfirmDialog.show(
      context: context,
      title: 'Excluir despesa?',
      message: 'Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (confirmed) {
      await ref.read(expensesControllerProvider.notifier).delete(expense.id);
    }
  }
}
