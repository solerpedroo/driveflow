import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/category_breakdown_slice.dart';
import '../../../../shared/widgets/driveflow_glass_card.dart';

/// Gráfico de pizza com distribuição de despesas por categoria.
class ExpensePieChart extends StatelessWidget {
  const ExpensePieChart({
    required this.slices,
    super.key,
  });

  final List<CategoryBreakdownSlice> slices;

  static const _palette = [
    AppColors.expenseCoral,
    AppColors.warningAmber,
    AppColors.infoBlue,
    AppColors.electricTeal,
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
    Color(0xFF64748B),
    Color(0xFF84CC16),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (slices.isEmpty) {
      return DriveFlowGlassCard(
        child: Text(
          'Nenhuma despesa no período.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return DriveFlowGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Despesas por categoria', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 36,
                      sections: [
                        for (var i = 0; i < slices.length; i++)
                          PieChartSectionData(
                            value: slices[i].amount,
                            color: _palette[i % _palette.length],
                            radius: 56,
                            title: '${(slices[i].share * 100).toStringAsFixed(0)}%',
                            titleStyle: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < slices.length && i < 5; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _palette[i % _palette.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  slices[i].category.label,
                                  style: theme.textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(slices[i].amount),
                                style: theme.textTheme.labelSmall,
                              ),
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
  }
}
