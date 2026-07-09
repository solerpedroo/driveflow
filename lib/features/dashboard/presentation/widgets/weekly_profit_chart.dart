import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/domain/models/daily_profit_point.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Gráfico de barras com lucro diário da semana atual.
class WeeklyProfitChart extends StatelessWidget {
  const WeeklyProfitChart({
    required this.points,
    super.key,
  });

  final List<DailyProfitPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxProfit = points.fold<double>(
      0,
      (max, point) => point.profit > max ? point.profit : max,
    );
    final chartMax = maxProfit <= 0 ? 100.0 : maxProfit * 1.2;

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lucro semanal', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: chartMax,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: chartMax / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.secondaryLabel(theme).withValues(alpha: 0.15),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= points.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            points[index].weekdayLabel,
                            style: theme.textTheme.labelSmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < points.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: points[i].profit.clamp(0, chartMax),
                          color: points[i].profit >= 0
                              ? AppColors.profitGreen
                              : AppColors.expenseCoral,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total: ${CurrencyFormatter.formatSigned(points.fold<double>(0, (s, p) => s + p.profit))}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.electricTeal,
            ),
          ),
        ],
      ),
    );
  }
}
