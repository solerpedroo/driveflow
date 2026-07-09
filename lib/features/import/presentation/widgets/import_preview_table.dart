import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../domain/entities/statement_transaction.dart';

/// Tabela premium de preview com seleção tátil.
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
        final disabled = transaction.isDuplicate;
        final accent = transaction.isCredit
            ? AppColors.profitGreen
            : AppColors.expenseCoral;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: transaction.selected
                  ? accent.withValues(alpha: 0.08)
                  : AppColors.mutedSurface(theme).withValues(alpha: 0.45),
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: transaction.selected
                    ? accent.withValues(alpha: 0.28)
                    : theme.dividerColor.withValues(alpha: 0.3),
              ),
            ),
            child: InkWell(
              borderRadius: AppRadius.mdAll,
              onTap: disabled
                  ? null
                  : () {
                      DfHaptics.selection();
                      onToggle(transaction.lineIndex, !transaction.selected);
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      transaction.selected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: disabled
                          ? AppColors.secondaryLabel(theme)
                          : transaction.selected
                              ? accent
                              : AppColors.secondaryLabel(theme),
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (transaction.suggestedCategory != null) ...[
                      Icon(
                        transaction.suggestedCategory!.icon,
                        color: AppColors.infoBlue,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: disabled
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${DateUtilsDriveFlow.dayMonthYear.format(transaction.date)} · '
                            '${transaction.type.label} · '
                            '${CurrencyFormatter.format(transaction.amount)}'
                            '${transaction.isDuplicate ? ' · duplicada' : ''}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.secondaryLabel(theme),
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
        );
      }).toList(growable: false),
    );
  }
}
