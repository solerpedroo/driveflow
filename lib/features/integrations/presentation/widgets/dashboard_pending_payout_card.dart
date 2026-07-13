import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../integrations/presentation/providers/platform_analytics_providers.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Resumo compacto de repasses pendentes no dashboard.
class DashboardPendingPayoutCard extends ConsumerWidget {
  const DashboardPendingPayoutCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entries = ref.watch(platformPayoutCalendarProvider);
    final pending = ref.watch(platformPendingPayoutProvider);

    return entries.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        if (data.isEmpty || pending <= 0) return const SizedBox.shrink();

        final next = data.first;

        return DfCard(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.profitGreen.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.profitGreen,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A receber',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${next.platform.label} · próximo repasse',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryLabel(theme),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                CurrencyFormatter.format(pending),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.profitGreen,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
