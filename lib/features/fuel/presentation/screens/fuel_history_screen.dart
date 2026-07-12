import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_expandable_list_section.dart';
import '../../../../shared/widgets/design_system/df_hero_wealth_card.dart';
import '../../../../shared/widgets/design_system/df_movimentacao_tile.dart';
import '../../../../shared/widgets/design_system/df_pill_action_button.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';
import '../../domain/entities/fuel_log_entity.dart';
import '../providers/fuel_providers.dart';

/// Histórico de abastecimentos — layout Mescla Carteira.
class FuelHistoryScreen extends ConsumerWidget {
  const FuelHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(activeVehicleFuelLogsProvider);
    final rollingAvg = ref.watch(rollingKmPerLiterProvider);
    final hidden = ref.watch(valueVisibilityHiddenProvider);
    final totalSpent = logsAsync.valueOrNull?.fold<double>(
          0,
          (sum, log) => sum + log.totalAmount,
        ) ??
        0;

    return DfSubpageScaffold(
      title: 'Abastecimentos',
      valueHidden: hidden,
      onToggleValueVisibility: () => ref
          .read(valueVisibilityHiddenProvider.notifier)
          .state = !hidden,
      children: [
        DfHeroWealthCard(
          label: 'Total abastecido',
          value: CurrencyFormatter.format(totalSpent),
          badge: rollingAvg.valueOrNull != null
              ? '${rollingAvg.value!.toStringAsFixed(1)} km/L'
              : '${logsAsync.valueOrNull?.length ?? 0} registros',
          hideValue: hidden,
        ),
        DfPillActionGrid(
          actions: [
            DfPillActionButton(
              icon: Icons.local_gas_station_rounded,
              label: 'Abastecer',
              onTap: () => context.push(AppRoutes.fuelLog),
            ),
            DfPillActionButton(
              icon: Icons.receipt_long_outlined,
              label: 'Despesas',
              onTap: () => context.go('${AppRoutes.home}?tab=expenses'),
            ),
            DfPillActionButton(
              icon: Icons.bar_chart_rounded,
              label: 'Relatórios',
              onTap: () => context.go('${AppRoutes.home}?tab=reports'),
            ),
            DfPillActionButton(
              icon: Icons.build_circle_outlined,
              label: 'Manutenção',
              onTap: () => context.push(AppRoutes.maintenanceHistory),
            ),
          ],
        ),
        logsAsync.when(
          loading: () => const DfSkeleton(itemCount: 3),
          error: (e, _) => Text('Não foi possível carregar. Tente novamente.'),
          data: (logs) {
            if (logs.isEmpty) {
              return const DfEmptyState(
                variant: DfEmptyStateVariant.illustrated,
                icon: Icons.local_gas_station_outlined,
                title: 'Nenhum abastecimento registrado',
                subtitle: 'Toque em Abastecer para registrar o primeiro.',
              );
            }
            return DfExpandableListSection(
              title: 'Histórico',
              eyebrow: 'Abastecimentos',
              itemCount: logs.length,
              itemBuilder: (context, index) => _FuelMovimentacaoTile(
                log: logs[index],
                hideValue: hidden,
                onDelete: () => _confirmDelete(context, ref, logs[index]),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    FuelLogEntity log,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir abastecimento?'),
        content: const Text(
          'A despesa de combustível vinculada também será removida.',
        ),
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
      await ref.read(fuelControllerProvider.notifier).delete(log.id);
    }
  }
}

class _FuelMovimentacaoTile extends StatelessWidget {
  const _FuelMovimentacaoTile({
    required this.log,
    required this.hideValue,
    required this.onDelete,
  });

  final FuelLogEntity log;
  final bool hideValue;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final title = log.station?.isNotEmpty == true
        ? log.station!
        : log.fuelType.label;

    return DfMovimentacaoTile(
      title: title,
      detailCaps:
          '${log.liters.toStringAsFixed(1)} L · ${log.odometerKm.toStringAsFixed(0)} km',
      dateLabel: log.createdAt != null
          ? DateUtilsDriveFlow.dateTime.format(log.createdAt!)
          : '—',
      amount: CurrencyFormatter.format(log.totalAmount),
      isCredit: false,
      hideValue: hideValue,
      onTap: () => context.push(AppRoutes.fuelLog, extra: log),
      onLongPress: onDelete,
    );
  }
}
