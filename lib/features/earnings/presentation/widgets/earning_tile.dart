import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/earning_entity.dart';
import '../providers/earnings_providers.dart';

/// Tile de ganho na listagem.
class EarningTile extends ConsumerWidget {
  const EarningTile({required this.earning, super.key});

  final EarningEntity earning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DfCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: () => context.push(AppRoutes.earningForm, extra: earning),
        onLongPress: () => _confirmDelete(context, ref),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    earning.platform.label,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateUtilsDriveFlow.dayMonthYear.format(earning.date)} · '
                    '${earning.rides} corridas · ${earning.workedHours}h',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryLabel(theme),
                    ),
                  ),
                  if (earning.note != null && earning.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      earning.note!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              CurrencyFormatter.format(earning.amount),
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.profitGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir ganho?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(earningsControllerProvider.notifier).delete(earning.id);
    }
  }
}
