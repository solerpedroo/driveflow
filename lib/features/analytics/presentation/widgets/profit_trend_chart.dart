import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/domain/models/daily_profit_point.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Gráfico de linha com lucro diário (30 ou 90 dias).
class ProfitTrendChart extends StatelessWidget {
  const ProfitTrendChart({
    required this.points,
    required this.windowLabel,
    super.key,
  });

  final List<DailyProfitPoint> points;
  final String windowLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (points.isEmpty) {
      return DfCard(
        child: Text(
          'Sem dados no período.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final profits = points.map((p) => p.profit).toList();
    final minProfit = profits.reduce((a, b) => a < b ? a : b);
    final maxProfit = profits.reduce((a, b) => a > b ? a : b);
    final padding = (maxProfit - minProfit).abs() * 0.15 + 20;
    final chartMin = minProfit - padding;
    final chartMax = maxProfit + padding;
    final showEvery = points.length > 45 ? (points.length / 6).floor() : 7;
    final total = profits.fold<double>(0, (s, p) => s + p);

    return Semantics(
      label:
          'Gráfico de tendência de lucro $windowLabel. Total ${CurrencyFormatter.formatSigned(total)}',
      child: RepaintBoundary(
        child: DfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tendência de lucro — $windowLabel',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    minY: chartMin,
                    maxY: chartMax,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: AppSemanticColors.chartGrid(theme),
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
                          interval: showEvery.toDouble(),
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 ||
                                index >= points.length ||
                                index % showEvery != 0) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                points[index].weekdayLabel,
                                style: theme.textTheme.labelSmall,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < points.length; i++)
                            FlSpot(i.toDouble(), points[i].profit),
                        ],
                        isCurved: true,
                        color: AppColors.electricTeal,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color:
                              AppColors.electricTeal.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Total: ${CurrencyFormatter.formatSigned(total)}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.electricTeal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
