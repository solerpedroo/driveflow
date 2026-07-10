import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../integrations/domain/entities/platform_revenue_trend_point.dart';
import '../../../integrations/domain/services/platform_revenue_trend_calculator.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Linhas múltiplas — evolução de receita por Uber/99/InDrive.
class PlatformRevenueTrendChart extends StatefulWidget {
  const PlatformRevenueTrendChart({
    required this.points,
    required this.deltas,
    super.key,
  });

  final List<PlatformRevenueTrendPoint> points;
  final Map<RidePlatform, double> deltas;

  static const _colors = {
    RidePlatform.uber: AppColors.deepNavy,
    RidePlatform.ninetyNine: AppColors.warningAmber,
    RidePlatform.inDrive: AppColors.profitGreen,
  };

  @override
  State<PlatformRevenueTrendChart> createState() =>
      _PlatformRevenueTrendChartState();
}

class _PlatformRevenueTrendChartState extends State<PlatformRevenueTrendChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: DriveFlowMotion.chart)
      ..forward();
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
        child: Text('Sem dados no período.', style: theme.textTheme.bodyMedium),
      );
    }

    final platforms = PlatformRevenueTrendCalculator.integratable.toList();
    final values = points.expand((p) => p.amountsByPlatform.values);
    final maxY = values.isEmpty
        ? 1.0
        : values.fold<double>(0, (m, v) => v > m ? v : m);

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.deltas.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final entry in widget.deltas.entries)
                  _DeltaChip(platform: entry.key, delta: entry.value),
              ],
            ),
          if (widget.deltas.isNotEmpty) const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, _) {
                return LineChart(
                  LineChartData(
                    maxY: maxY * 1.2 * _anim.value + 1,
                    minY: 0,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: (points.length / 5).ceilToDouble(),
                          getTitlesWidget: (value, _) {
                            final i = value.toInt();
                            if (i < 0 || i >= points.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              points[i].weekdayLabel,
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
                    lineBarsData: [
                      for (final platform in platforms)
                        if (points.any(
                          (p) => (p.amountsByPlatform[platform] ?? 0) > 0,
                        ))
                          LineChartBarData(
                            spots: [
                              for (var i = 0; i < points.length; i++)
                                FlSpot(
                                  i.toDouble(),
                                  (points[i].amountsByPlatform[platform] ?? 0) *
                                      _anim.value,
                                ),
                            ],
                            isCurved: true,
                            color: PlatformRevenueTrendChart._colors[platform],
                            barWidth: 2.5,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 12,
            children: [
              for (final platform in platforms)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: PlatformRevenueTrendChart._colors[platform],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(platform.label, style: theme.textTheme.labelSmall),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.platform, required this.delta});

  final RidePlatform platform;
  final double delta;

  @override
  Widget build(BuildContext context) {
    final positive = delta >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (positive ? AppColors.profitGreen : AppColors.expenseCoral)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${positive ? '+' : ''}${delta.toStringAsFixed(0)}% ${platform.label}',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: positive ? AppColors.profitGreen : AppColors.expenseCoral,
            ),
      ),
    );
  }
}
