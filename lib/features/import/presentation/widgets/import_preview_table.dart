import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/statement_transaction.dart';

/// Tabela de preview com checkboxes para importação.
class ImportPreviewTable extends StatelessWidget {
  const ImportPreviewTable({
    required this.transactions,
    required this.onToggle,
    super.key,
  });

  final List<StatementTransaction> transactions;
  final void Function(int lineIndex, bool selected) onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (transactions.isEmpty) {
      return Text(
        'Nenhuma linha válida encontrada.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.secondaryLabel(theme),
        ),
      );
    }

    return Column(
      children: transactions.take(50).map((transaction) {
        return CheckboxListTile(
          value: transaction.selected,
          onChanged: transaction.isDuplicate
              ? null
              : (value) => onToggle(transaction.lineIndex, value ?? false),
          title: Text(
            transaction.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${DateUtilsDriveFlow.dayMonthYear.format(transaction.date)} · '
            '${transaction.type.label} · '
            '${CurrencyFormatter.format(transaction.amount)}'
            '${transaction.isDuplicate ? ' · duplicada' : ''}',
          ),
          secondary: transaction.suggestedCategory != null
              ? Icon(
                  transaction.suggestedCategory!.icon,
                  color: AppColors.infoBlue,
                )
              : null,
        );
      }).toList(growable: false),
    );
  }
}
