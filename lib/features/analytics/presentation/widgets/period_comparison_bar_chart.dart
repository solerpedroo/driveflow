import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../domain/entities/period_comparison_result.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Barras comparativas premium — gradiente, animação e tooltip tátil.
class PeriodComparisonBarChart extends StatefulWidget {
  const PeriodComparisonBarChart({
    required this.comparison,
    super.key,
  });

  final PeriodComparisonResult comparison;

  @override
  State<PeriodComparisonBarChart> createState() =>
      _PeriodComparisonBarChartState();
}

class _PeriodComparisonBarChartState extends State<PeriodComparisonBarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  int? _touchedGroup;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: DriveFlowMotion.chart,
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bars = widget.comparison.metrics
        .where((m) => ['Receita', 'Despesas', 'Lucro'].contains(m.label))
        .toList();

    if (bars.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValue = bars.fold<double>(0, (max, metric) {
      final localMax = metric.current > metric.previous
          ? metric.current
          : metric.previous;
      return localMax > max ? localMax : max;
    });
    final chartMax = maxValue <= 0 ? 100.0 : maxValue * 1.25;

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Atual vs referência',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              return SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    maxY: chartMax,
                    minY: 0,
                    groupsSpace: 18,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchCallback: (event, response) {
                        if (!event.isInterestedForInteractions) {
                          setState(() => _touchedGroup = null);
                          return;
                        }
                        final index = response?.spot?.touchedBarGroupIndex;
                        if (index != null && index != _touchedGroup) {
                          DfHaptics.light();
                        }
                        setState(() => _touchedGroup = index);
                      },
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) =>
                            AppColors.deepNavy.withValues(alpha: 0.92),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final metric = bars[group.x.toInt()];
                          final isCurrent = rodIndex == 1;
                          final value =
                              isCurrent ? metric.current : metric.previous;
                          final label = isCurrent ? 'Atual' : 'Referência';
                          return BarTooltipItem(
                            '${metric.label} ($label)\n${CurrencyFormatter.format(value)}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: chartMax / 4,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: AppColors.secondaryLabel(theme)
                            .withValues(alpha: 0.12),
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
                            final isTouched = index == _touchedGroup;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                bars[index].label,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isTouched
                                      ? AppColors.skyBlue
                                      : AppColors.secondaryLabel(theme),
                                  fontWeight: isTouched
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
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
                              toY: bars[i].previous.clamp(0, chartMax) *
                                  _anim.value,
                              width: _touchedGroup == i ? 14 : 12,
                              color: AppColors.secondaryLabel(theme)
                                  .withValues(alpha: 0.45),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                            BarChartRodData(
                              toY: bars[i].current.clamp(0, chartMax) *
                                  _anim.value,
                              width: _touchedGroup == i ? 14 : 12,
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: _barColors(bars[i].label),
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ],
                          barsSpace: 4,
                        ),
                    ],
                  ),
                  duration: DriveFlowMotion.fast,
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _LegendDot(
                color: AppColors.secondaryLabel(theme).withValues(alpha: 0.45),
                label: 'Referência',
              ),
              const SizedBox(width: 16),
              const _LegendDot(
                color: AppColors.skyBlue,
                label: 'Atual',
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Color> _barColors(String label) {
    return switch (label) {
      'Receita' => [
          AppColors.profitGreen.withValues(alpha: 0.55),
          AppColors.profitGreen,
        ],
      'Despesas' => [
          AppColors.expenseCoral.withValues(alpha: 0.55),
          AppColors.expenseCoral,
        ],
      _ => [
          AppColors.skyBlue.withValues(alpha: 0.55),
          AppColors.skyBlue,
        ],
    };
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
