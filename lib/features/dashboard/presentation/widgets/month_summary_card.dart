import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/domain/models/period_summary.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Resumo financeiro do mês corrente.
class MonthSummaryCard extends StatelessWidget {
  const MonthSummaryCard({
    required this.summary,
    super.key,
  });

  final PeriodSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profitColor =
        summary.profit >= 0 ? AppColors.profitGreen : AppColors.expenseCoral;

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumo do mês', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _Row(label: 'Receita', value: CurrencyFormatter.format(summary.revenue)),
          _Row(label: 'Despesas', value: CurrencyFormatter.format(summary.expenses)),
          _Row(
            label: 'Lucro',
            value: CurrencyFormatter.formatSigned(summary.profit),
            valueColor: profitColor,
          ),
          if (summary.profitPerHour != null) ...[
            const Divider(height: 20),
            _Row(
              label: 'Lucro / hora',
              value: CurrencyFormatter.format(summary.profitPerHour!),
            ),
          ],
          if (summary.profitPerKm != null)
            _Row(
              label: 'Lucro / km',
              value: CurrencyFormatter.format(summary.profitPerKm!),
            ),
          if (summary.avgCostPerKm != null)
            _Row(
              label: 'Custo / km (comb.)',
              value: CurrencyFormatter.format(summary.avgCostPerKm!),
            ),
          _Row(
            label: 'Combustível',
            value: CurrencyFormatter.format(summary.fuelExpense),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
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
      padding: const EdgeInsets.only(bottom: 6),
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
