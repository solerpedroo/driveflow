import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/domain/models/period_summary.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Breakdown do mês — módulo elevado com linhas editoriais.
class MonthSummaryCard extends StatelessWidget {
  const MonthSummaryCard({
    required this.summary,
    this.hideHeroProfit = false,
    this.hideValue = false,
    super.key,
  });

  final PeriodSummary summary;
  final bool hideHeroProfit;
  final bool hideValue;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final profitColor =
        summary.profit >= 0 ? AppColors.profitGreen : AppColors.expenseCoral;

    final rows = <_MetricRowData>[
      _MetricRowData(
        label: 'Receita',
        value: maskCurrency(
          CurrencyFormatter.format(summary.revenue),
          hidden: hideValue,
        ),
      ),
      _MetricRowData(
        label: 'Despesas',
        value: maskCurrency(
          CurrencyFormatter.format(summary.expenses),
          hidden: hideValue,
        ),
      ),
      if (summary.profitPerHour != null)
        _MetricRowData(
          label: 'Lucro / hora',
          value: maskCurrency(
            CurrencyFormatter.format(summary.profitPerHour!),
            hidden: hideValue,
          ),
          emphasized: true,
        ),
      if (summary.profitPerKm != null)
        _MetricRowData(
          label: 'Lucro / km',
          value: maskCurrency(
            CurrencyFormatter.format(summary.profitPerKm!),
            hidden: hideValue,
          ),
        ),
      if (summary.avgCostPerKm != null)
        _MetricRowData(
          label: 'Custo / km (comb.)',
          value: maskCurrency(
            CurrencyFormatter.format(summary.avgCostPerKm!),
            hidden: hideValue,
          ),
        ),
      _MetricRowData(
        label: 'Combustível',
        value: maskCurrency(
          CurrencyFormatter.format(summary.fuelExpense),
          hidden: hideValue,
        ),
      ),
    ];

    return DfCard(
      variant: DfCardVariant.elevated,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalhes do mês',
            style: AppTypography.labelCaps(brightness),
          ),
          if (!hideHeroProfit) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              maskCurrency(
                CurrencyFormatter.formatSigned(summary.profit),
                hidden: hideValue,
              ),
              style: AppTypography.metric(
                brightness,
                fontSize: 28,
                color: hideValue
                    ? Theme.of(context).colorScheme.onSurface
                    : profitColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'lucro líquido',
              style: AppTypography.iosFootnote(brightness),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 0.5,
                color: AppElevation.hairline(brightness).color,
              ),
            _MetricRow(data: rows[i]),
          ],
        ],
      ),
    );
  }
}

class _MetricRowData {
  const _MetricRowData({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.data});

  final _MetricRowData data;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              data.label,
              style: AppTypography.iosBody(brightness).copyWith(
                color: AppColors.secondaryLabel(Theme.of(context)),
                fontSize: 15,
              ),
            ),
          ),
          Text(
            data.value,
            style: AppTypography.iosHeadline(brightness).copyWith(
              fontSize: data.emphasized ? 17 : 15,
              fontWeight: data.emphasized ? FontWeight.w700 : FontWeight.w600,
              color: data.emphasized ? AppColors.brandBlue : null,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
