import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../integrations/domain/entities/platform_payout_entry.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../providers/platform_analytics_providers.dart';

/// Calendário de repasses estimados por app.
class PlatformPayoutCalendarCard extends ConsumerWidget {
  const PlatformPayoutCalendarCard({super.key});

  static final _dateFormat = DateFormat('dd/MM', 'pt_BR');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entries = ref.watch(platformPayoutCalendarProvider);
    final pending = ref.watch(platformPendingPayoutProvider);

    return entries.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();

        final upcoming = data.take(5).toList();

        return DfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'A receber',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(pending),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.profitGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              for (final entry in upcoming) _EntryRow(entry: entry),
            ],
          ),
        );
      },
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});

  final PlatformPayoutEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(
            PlatformPayoutCalendarCard._dateFormat.format(entry.expectedDate),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${entry.platform.label} · ${entry.tripCount} corridas',
              style: theme.textTheme.bodySmall,
            ),
          ),
          Text(
            CurrencyFormatter.format(entry.amount),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
