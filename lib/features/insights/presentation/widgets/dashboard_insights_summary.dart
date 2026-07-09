import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/earning_time_slot.dart';
import '../../domain/entities/maintenance_prediction.dart';

/// Resumo compacto de insights para o Dashboard.
class DashboardInsightsSummary extends StatelessWidget {
  const DashboardInsightsSummary({
    required this.topSlots,
    required this.topPrediction,
    super.key,
  });

  final List<EarningTimeSlot> topSlots;
  final MaintenancePrediction? topPrediction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasContent = topSlots.isNotEmpty || topPrediction != null;
    if (!hasContent) return const SizedBox.shrink();

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_outlined,
                  color: AppColors.electricTeal),
              const SizedBox(width: 8),
              Text('Insights rápidos', style: theme.textTheme.titleMedium),
            ],
          ),
          if (topSlots.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Melhor janela: ${topSlots.first.weekdayLabel} '
              '${topSlots.first.hourLabel} · '
              '${CurrencyFormatter.format(topSlots.first.profitPerHour)}/h',
              style: theme.textTheme.bodyMedium,
            ),
          ],
          if (topPrediction != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    topPrediction!.summaryLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.warningAmber,
                    ),
                  ),
                ),
                Chip(
                  label: Text(topPrediction!.confidence.label),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
