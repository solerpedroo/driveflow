import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/design_system/df_movimentacao_tile.dart';
import '../../domain/entities/earning_entity.dart';
import '../providers/earnings_providers.dart';

/// Tile de ganho — padrão Mescla movimentação.
class EarningTile extends ConsumerWidget {
  const EarningTile({
    required this.earning,
    super.key,
    this.hideValue = false,
  });

  final EarningEntity earning;
  final bool hideValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DfMovimentacaoTile(
      title: earning.platform.label,
      detailCaps:
          '${earning.rides} corridas · ${earning.workedHours}h trabalhadas',
      dateLabel: DateUtilsDriveFlow.dayMonthYear.format(earning.date),
      amount: CurrencyFormatter.format(earning.amount),
      isCredit: true,
      hideValue: hideValue,
      onTap: () => context.push(AppRoutes.earningForm, extra: earning),
      onLongPress: () => _confirmDelete(context, ref),
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
