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
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../../domain/services/maintenance_due_checker.dart';
import '../providers/maintenance_providers.dart';

/// Histórico de manutenções — layout Mescla Carteira.
class MaintenanceHistoryScreen extends ConsumerWidget {
  const MaintenanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(activeVehicleMaintenanceProvider);
    final odometer =
        ref.watch(activeVehicleProvider).valueOrNull?.odometerKm ?? 0;
    final hidden = ref.watch(valueVisibilityHiddenProvider);
    final totalCost = recordsAsync.valueOrNull?.fold<double>(
          0,
          (sum, r) => sum + r.cost,
        ) ??
        0;

    return DfSubpageScaffold(
      title: 'Manutenções',
      valueHidden: hidden,
      onToggleValueVisibility: () => ref
          .read(valueVisibilityHiddenProvider.notifier)
          .state = !hidden,
      children: [
        DfHeroWealthCard(
          label: 'Total investido',
          value: CurrencyFormatter.format(totalCost),
          badge: '${recordsAsync.valueOrNull?.length ?? 0} serviços',
          hideValue: hidden,
        ),
        DfPillActionGrid(
          actions: [
            DfPillActionButton(
              icon: Icons.build_circle_outlined,
              label: 'Registrar',
              onTap: () => context.push(AppRoutes.maintenanceForm),
            ),
            DfPillActionButton(
              icon: Icons.local_gas_station_outlined,
              label: 'Combustível',
              onTap: () => context.push(AppRoutes.fuelHistory),
            ),
            DfPillActionButton(
              icon: Icons.auto_awesome_outlined,
              label: 'Insights',
              onTap: () => context.push(AppRoutes.insights),
            ),
            DfPillActionButton(
              icon: Icons.directions_car_outlined,
              label: 'Veículos',
              onTap: () => context.go('${AppRoutes.home}?tab=profile'),
            ),
          ],
        ),
        recordsAsync.when(
          loading: () => const DfSkeleton(itemCount: 3),
          error: (e, _) => Text('Não foi possível carregar. Tente novamente.'),
          data: (records) {
            if (records.isEmpty) {
              return const DfEmptyState(
                variant: DfEmptyStateVariant.illustrated,
                icon: Icons.build_circle_outlined,
                title: 'Nenhuma manutenção registrada',
                subtitle: 'Toque em Registrar para cadastrar a primeira.',
              );
            }
            return DfExpandableListSection(
              title: 'Histórico',
              eyebrow: 'Serviços',
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                final status = MaintenanceDueChecker.check(
                  record: record,
                  currentOdometerKm: odometer,
                );
                return _MaintenanceMovimentacaoTile(
                  record: record,
                  status: status,
                  hideValue: hidden,
                  onDelete: () => _confirmDelete(context, ref, record),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MaintenanceEntity record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir manutenção?'),
        content: const Text('O lembrete agendado também será cancelado.'),
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
      await ref.read(maintenanceControllerProvider.notifier).delete(record.id);
    }
  }
}

class _MaintenanceMovimentacaoTile extends StatelessWidget {
  const _MaintenanceMovimentacaoTile({
    required this.record,
    required this.status,
    required this.hideValue,
    required this.onDelete,
  });

  final MaintenanceEntity record;
  final MaintenanceDueStatus status;
  final bool hideValue;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return DfMovimentacaoTile(
      title: record.type.label,
      detailCaps: status.label,
      dateLabel: DateUtilsDriveFlow.dayMonthYear.format(record.serviceDate),
      amount: CurrencyFormatter.format(record.cost),
      isCredit: false,
      hideValue: hideValue,
      onTap: () => context.push(AppRoutes.maintenanceForm, extra: record),
      onLongPress: onDelete,
    );
  }
}
