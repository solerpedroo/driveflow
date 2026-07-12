import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../integrations/domain/services/platform_analytics_breakdown.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Donut — mix de receita de hoje por app.
class PlatformRevenueDonutChart extends StatefulWidget {
  const PlatformRevenueDonutChart({required this.slices, super.key});

  final List<PlatformRevenueSlice> slices;

  static const _palette = [
    AppColors.brandBlue,
    AppColors.brandBlueDark,
    AppColors.deepNavy,
  ];

  @override
  State<PlatformRevenueDonutChart> createState() =>
      _PlatformRevenueDonutChartState();
}

class _PlatformRevenueDonutChartState extends State<PlatformRevenueDonutChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  int? _touchedIndex;

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
    final brightness = theme.brightness;
    final slices = widget.slices;

    if (slices.isEmpty) return const SizedBox.shrink();

    return DfCard(
      variant: DfCardVariant.elevated,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Onde você rodou',
            style: AppTypography.labelCaps(brightness),
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              return SizedBox(
                height: 148,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 34,
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              if (!event.isInterestedForInteractions) {
                                setState(() => _touchedIndex = null);
                                return;
                              }
                              final index = response
                                  ?.touchedSection?.touchedSectionIndex;
                              if (index != null && index != _touchedIndex) {
                                DfHaptics.light();
                              }
                              setState(() => _touchedIndex = index);
                            },
                          ),
                          sections: [
                            for (var i = 0; i < slices.length; i++)
                              PieChartSectionData(
                                value: slices[i].amount * _anim.value,
                                color: PlatformRevenueDonutChart._palette[i %
                                    PlatformRevenueDonutChart._palette.length],
                                radius: _touchedIndex == i ? 50 : 44,
                                title:
                                    '${slices[i].sharePercent.toStringAsFixed(0)}%',
                                titleStyle: AppTypography.iosCaption(brightness)
                                    .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < slices.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      color: PlatformRevenueDonutChart
                                              ._palette[
                                          i %
                                              PlatformRevenueDonutChart
                                                  ._palette.length],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      slices[i].platform.label,
                                      style: AppTypography.iosCaption(brightness)
                                          .copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(slices[i].amount),
                                    style: AppTypography.iosCaption(brightness)
                                        .copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
