import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/widgets/design_system/df_movimentacao_tile.dart';
import '../../domain/entities/shift_history_entry.dart';
import '../widgets/shift_adherence_badge.dart';
import '../widgets/shift_timer_widget.dart';

/// Linha do histórico de turnos.
class ShiftHistoryTile extends ConsumerWidget {
  const ShiftHistoryTile({
    required this.entry,
    required this.onTap,
    super.key,
  });

  final ShiftHistoryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(valueVisibilityHiddenProvider);

    return DfMovimentacaoTile(
      title: DateUtilsDriveFlow.dayMonthYear.format(entry.startedAt),
      detailCaps: entry.expenses > 0
          ? '${ShiftTimerWidget.format(entry.elapsed)} · '
              '${entry.rides} corridas · líquido'
          : '${ShiftTimerWidget.format(entry.elapsed)} · ${entry.rides} corridas',
      dateLabel: entry.totalPlanBlocks > 0
          ? 'Aderência ${entry.adherenceScore.round()}%'
          : entry.isTaxiMode
              ? 'Taxista'
              : 'Turno',
      amount: CurrencyFormatter.format(
        entry.expenses > 0 ? entry.netCash : entry.revenue,
      ),
      isCredit: entry.expenses > 0 ? entry.netCash >= 0 : true,
      hideValue: hidden,
      onTap: onTap,
      leading: entry.totalPlanBlocks > 0
          ? ShiftAdherenceBadge(score: entry.adherenceScore)
          : Icon(
              Icons.timer_rounded,
              color: AppColors.brandBlue.withValues(alpha: 0.85),
            ),
    );
  }
}
