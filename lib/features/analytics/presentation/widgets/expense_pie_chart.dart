import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../domain/entities/category_breakdown_slice.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Gráfico donut de despesas por categoria — legenda legível e fatia única sem artefato.
class ExpensePieChart extends StatefulWidget {
  const ExpensePieChart({
    required this.slices,
    super.key,
  });

  final List<CategoryBreakdownSlice> slices;

  static const _palette = [
    AppColors.expenseCoral,
    AppColors.warningAmber,
    AppColors.infoBlue,
    AppColors.skyBlue,
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
    Color(0xFF64748B),
    Color(0xFF84CC16),
  ];

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart>
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

  Color _legendColor(ThemeData theme, {required bool emphasized}) {
    if (theme.brightness == Brightness.dark) {
      return emphasized ? Colors.white : const Color(0xFFAEAEB2);
    }
    return emphasized ? AppColors.brandNavy : AppColors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slices = widget.slices;

    if (slices.isEmpty) {
      return DfCard(
        child: Text(
          'Nenhuma despesa no período.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final isSingleSlice = slices.length == 1;
    final legend = slices.take(5).map((s) => s.category.label).join(', ');

    return Semantics(
      label: 'Gráfico de despesas por categoria: $legend',
      child: RepaintBoundary(
        child: DfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Despesas por categoria',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AnimatedBuilder(
                animation: _anim,
                builder: (context, _) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 11,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  startDegreeOffset: -90,
                                  sectionsSpace: isSingleSlice ? 0 : 2,
                                  centerSpaceRadius: 42,
                                  borderData: FlBorderData(show: false),
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
                                        color: ExpensePieChart._palette[
                                            i % ExpensePieChart._palette.length],
                                        radius: _touchedIndex == i ? 50 : 46,
                                        showTitle: !isSingleSlice &&
                                            slices[i].share >= 0.08,
                                        title:
                                            '${(slices[i].share * 100).toStringAsFixed(0)}%',
                                        titleStyle: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                        titlePositionPercentageOffset: 0.55,
                                      ),
                                  ],
                                ),
                                duration: DriveFlowMotion.fast,
                              ),
                              if (isSingleSlice)
                                Text(
                                  '100%',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: _legendColor(theme, emphasized: true),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 13,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < slices.length && i < 5; i++)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: _touchedIndex == i ? 12 : 10,
                                      height: _touchedIndex == i ? 12 : 10,
                                      decoration: BoxDecoration(
                                        color: ExpensePieChart._palette[
                                            i % ExpensePieChart._palette.length],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        slices[i].category.label,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: _touchedIndex == i
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: _legendColor(
                                            theme,
                                            emphasized: _touchedIndex == i,
                                          ),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      CurrencyFormatter.format(slices[i].amount),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: _legendColor(
                                          theme,
                                          emphasized: true,
                                        ),
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
