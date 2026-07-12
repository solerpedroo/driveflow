import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../integrations/domain/entities/platform_net_profit_slice.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Barras duplas — bruto vs líquido por app.
class PlatformNetProfitChart extends StatelessWidget {
  const PlatformNetProfitChart({required this.slices, super.key});

  final List<PlatformNetProfitSlice> slices;

  static const _colors = [
    AppColors.deepNavy,
    AppColors.warningAmber,
    AppColors.profitGreen,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (slices.isEmpty) {
      return DfCard(
        child: Text('Sem corridas dos apps ainda.', style: theme.textTheme.bodyMedium),
      );
    }

    final maxY = slices
        .map((s) => s.grossAmount > s.netAmount ? s.grossAmount : s.netAmount)
        .reduce((a, b) => a > b ? a : b);
    final minY = slices
        .map((s) => s.netAmount < 0 ? s.netAmount : 0)
        .reduce((a, b) => a < b ? a : b);

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bruto vs líquido',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY * 1.2,
                minY: minY < 0 ? minY * 1.2 : 0,
                groupsSpace: 16,
                barGroups: [
                  for (var i = 0; i < slices.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: slices[i].grossAmount,
                          color: _colors[i % _colors.length].withValues(alpha: 0.35),
                          width: 12,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: slices[i].netAmount,
                          color: _colors[i % _colors.length],
                          width: 12,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final i = value.toInt();
                        if (i < 0 || i >= slices.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          slices[i].platform.label,
                          style: theme.textTheme.labelSmall,
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final slice in slices)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${slice.platform.label}: líquido ${CurrencyFormatter.format(slice.netAmount)} '
                '(${slice.netSharePercent.toStringAsFixed(0)}% do bruto)',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.secondaryLabel(theme),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
