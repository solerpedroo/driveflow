import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../providers/shift_history_providers.dart';

/// Resumo dos últimos turnos no dashboard.
class DashboardShiftWeekCard extends ConsumerWidget {
  const DashboardShiftWeekCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(shiftHistoryWeekStatsProvider);
    if (stats.shiftCount == 0) return const SizedBox.shrink();

    final hidden = ref.watch(valueVisibilityHiddenProvider);
    final theme = Theme.of(context);

    final displayedAmount = stats.hasNetCashTracking ? stats.netCash : stats.revenue;
    final amountLabel = stats.hasNetCashTracking ? 'líquido' : 'faturado';
    final amountText = hidden
        ? '•••'
        : stats.hasNetCashTracking
            ? CurrencyFormatter.formatSigned(displayedAmount)
            : CurrencyFormatter.format(displayedAmount);

    return DfCard(
      onTap: () => context.push(AppRoutes.shiftAnalytics),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Últimos 7 dias',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.insights_rounded,
                size: 18,
                color: AppColors.brandBlue,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${stats.shiftCount} turnos · '
            '$amountText '
            '$amountLabel · '
            '${stats.rides} corridas',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryLabel(theme),
              height: 1.4,
            ),
          ),
          if (stats.avgAdherence > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Aderência média ${stats.avgAdherence.round()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.brandBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
