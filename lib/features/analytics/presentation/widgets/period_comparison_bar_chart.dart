import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/period_comparison_result.dart';
import '../../../../shared/widgets/driveflow_glass_card.dart';

/// Barras comparativas: período atual vs referência (receita, despesa, lucro).
class PeriodComparisonBarChart extends StatelessWidget {
  const PeriodComparisonBarChart({
    required this.comparison,
    super.key,
  });

  final PeriodComparisonResult comparison;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bars = comparison.metrics
        .where((m) => ['Receita', 'Despesas', 'Lucro'].contains(m.label))
        .toList();

    if (bars.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValue = bars.fold<double>(0, (max, metric) {
      final localMax = metric.current > metric.previous ? metric.current : metric.previous;
      return localMax > max ? localMax : max;
    });
    final chartMax = maxValue <= 0 ? 100.0 : maxValue * 1.25;

    return DriveFlowGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Atual vs referência', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: chartMax,
                minY: 0,
                groupsSpace: 18,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: chartMax / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color:
                        AppColors.secondaryLabel(theme).withValues(alpha: 0.12),
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
                        if (index < 0 || index >= bars.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            bars[index].label,
                            style: theme.textTheme.labelSmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < bars.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: bars[i].previous.clamp(0, chartMax),
                          color: AppColors.secondaryLabel(theme)
                              .withValues(alpha: 0.45),
                          width: 12,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: bars[i].current.clamp(0, chartMax),
                          color: AppColors.electricTeal,
                          width: 12,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                      barsSpace: 4,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _LegendDot(
                color: AppColors.secondaryLabel(theme).withValues(alpha: 0.45),
                label: 'Referência',
              ),
              const SizedBox(width: 16),
              const _LegendDot(
                color: AppColors.electricTeal,
                label: 'Atual',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
