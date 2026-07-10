import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../integrations/domain/services/platform_analytics_breakdown.dart';

/// Gráfico de barras — receita por Uber/99/InDrive.
class PlatformRevenueChart extends StatelessWidget {
  const PlatformRevenueChart({required this.slices, super.key});

  final List<PlatformRevenueSlice> slices;

  static const _colors = [
    AppColors.deepNavy,
    AppColors.warningAmber,
    AppColors.profitGreen,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxY = slices.map((s) => s.amount).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.2,
          barGroups: [
            for (var i = 0; i < slices.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: slices[i].amount,
                    color: _colors[i % _colors.length],
                    width: 28,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
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
                  final index = value.toInt();
                  if (index < 0 || index >= slices.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    slices[index].platform.label,
                    style: theme.textTheme.labelSmall,
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
