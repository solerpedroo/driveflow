import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/domain/models/period_summary.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Resumo do mês — breakdown sem repetir o lucro do hero.
class MonthSummaryCard extends StatelessWidget {
  const MonthSummaryCard({
    required this.summary,
    this.hideHeroProfit = false,
    super.key,
  });

  final PeriodSummary summary;
  final bool hideHeroProfit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final profitColor =
        summary.profit >= 0 ? AppColors.profitGreen : AppColors.expenseCoral;

    return DfCard(
      variant: DfCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalhes do mês',
            style: AppTypography.iosHeadline(brightness).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (!hideHeroProfit) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              CurrencyFormatter.formatSigned(summary.profit),
              style: AppTypography.metric(
                brightness,
                fontSize: 32,
                color: profitColor,
              ),
            ),
            Text(
              'lucro líquido do mês',
              style: AppTypography.iosFootnote(brightness),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _Row(label: 'Receita', value: CurrencyFormatter.format(summary.revenue)),
          _Row(label: 'Despesas', value: CurrencyFormatter.format(summary.expenses)),
          if (summary.profitPerHour != null) ...[
            const Divider(height: AppSpacing.lg),
            _Row(
              label: 'Lucro / hora',
              value: CurrencyFormatter.format(summary.profitPerHour!),
              emphasized: true,
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
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.iosBody(brightness).copyWith(
                color: AppColors.secondaryLabel(Theme.of(context)),
              ),
            ),
          ),
          Text(
            value,
            style: (emphasized
                    ? AppTypography.iosHeadline(brightness)
                    : AppTypography.iosBody(brightness))
                .copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
