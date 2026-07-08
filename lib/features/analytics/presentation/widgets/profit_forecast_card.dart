import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/driveflow_glass_card.dart';
import '../../domain/entities/profit_forecast_result.dart';

/// Card de projeção de lucro (7/30 dias).
class ProfitForecastCard extends StatelessWidget {
  const ProfitForecastCard({
    required this.forecast,
    this.aiSummary,
    this.isLoadingAi = false,
    this.onRequestAi,
    super.key,
  });

  final ProfitForecastResult forecast;
  final String? aiSummary;
  final bool isLoadingAi;
  final VoidCallback? onRequestAi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DriveFlowGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, color: AppColors.profitGreen),
              const SizedBox(width: 8),
              Text('Projeção', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Média diária: ${CurrencyFormatter.format(forecast.averageDailyProfit)} '
            '(${forecast.sampleDays} dias com movimento)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryLabel(theme),
            ),
          ),
          const SizedBox(height: 8),
          _Row(
            label: '7 dias',
            value: CurrencyFormatter.format(forecast.forecast7Days),
          ),
          _Row(
            label: '30 dias (base)',
            value: CurrencyFormatter.format(forecast.forecast30Days),
          ),
          _Row(
            label: '30 dias otimista',
            value: CurrencyFormatter.format(forecast.optimistic30Days),
            color: AppColors.profitGreen,
          ),
          _Row(
            label: '30 dias pessimista',
            value: CurrencyFormatter.format(forecast.pessimistic30Days),
            color: AppColors.warningAmber,
          ),
          if (aiSummary != null) ...[
            const SizedBox(height: 12),
            Text(aiSummary!, style: theme.textTheme.bodyMedium),
          ],
          if (onRequestAi != null) ...[
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: isLoadingAi ? null : onRequestAi,
              icon: isLoadingAi
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_outlined),
              label: Text(isLoadingAi ? 'Gerando análise…' : 'Análise IA'),
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
