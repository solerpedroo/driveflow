import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../../shared/domain/models/daily_profit_point.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Gráfico de linha premium — gradiente, animação e tooltip tátil.
class ProfitTrendChart extends StatefulWidget {
  const ProfitTrendChart({
    required this.points,
    required this.windowLabel,
    super.key,
  });

  final List<DailyProfitPoint> points;
  final String windowLabel;

  @override
  State<ProfitTrendChart> createState() => _ProfitTrendChartState();
}

class _ProfitTrendChartState extends State<ProfitTrendChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  int? _touchedIndex;

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
    final points = widget.points;

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
    final lineGradient = AppGradients.heroRing(
      theme.brightness,
      AppColors.skyBlue,
    );

    return Semantics(
      label:
          'Gráfico de tendência de lucro ${widget.windowLabel}. Total ${CurrencyFormatter.formatSigned(total)}',
      child: RepaintBoundary(
        child: DfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tendência de lucro — ${widget.windowLabel}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatSigned(total),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: total >= 0
                          ? AppColors.profitGreen
                          : AppColors.expenseCoral,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AnimatedBuilder(
                animation: _anim,
                builder: (context, _) {
                  final visibleCount =
                      (_anim.value * points.length).ceil().clamp(1, points.length);
                  final visibleSpots = [
                    for (var i = 0; i < visibleCount; i++)
                      FlSpot(i.toDouble(), points[i].profit),
                  ];

                  return SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        minY: chartMin,
                        maxY: chartMax,
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchCallback: (event, response) {
                            if (!event.isInterestedForInteractions) {
                              setState(() => _touchedIndex = null);
                              return;
                            }
                            final index = response?.lineBarSpots?.firstOrNull?.x
                                .toInt();
                            if (index != null && index != _touchedIndex) {
                              DfHaptics.light();
                            }
                            setState(() => _touchedIndex = index);
                          },
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) =>
                                AppColors.deepNavy.withValues(alpha: 0.92),
                            getTooltipItems: (spots) => spots.map((spot) {
                              final p = points[spot.x.toInt()];
                              return LineTooltipItem(
                                '${p.weekdayLabel}\n${CurrencyFormatter.formatSigned(p.profit)}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
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
                                final isTouched = index == _touchedIndex;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    points[index].weekdayLabel,
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
                        lineBarsData: [
                          LineChartBarData(
                            spots: visibleSpots,
                            isCurved: true,
                            gradient: lineGradient,
                            barWidth: _touchedIndex != null ? 4 : 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: _touchedIndex != null,
                              getDotPainter: (spot, percent, bar, index) {
                                if (index != _touchedIndex) {
                                  return FlDotCirclePainter(
                                    radius: 0,
                                    color: Colors.transparent,
                                  );
                                }
                                return FlDotCirclePainter(
                                  radius: 5,
                                  color: AppColors.skyBlue,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.skyBlue.withValues(alpha: 0.22),
                                  AppColors.skyBlue.withValues(alpha: 0.02),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      duration: DriveFlowMotion.fast,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
