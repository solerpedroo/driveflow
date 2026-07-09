import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../../domain/services/maintenance_due_checker.dart';
import '../providers/maintenance_providers.dart';

/// Histórico de manutenções com status de vencimento.
class MaintenanceHistoryScreen extends ConsumerWidget {
  const MaintenanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recordsAsync = ref.watch(activeVehicleMaintenanceProvider);
    final odometer = ref.watch(activeVehicleProvider).valueOrNull?.odometerKm ?? 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Manutenções'),
        backgroundColor: Colors.transparent,
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (records) {
          if (records.isEmpty) {
            return const DfEmptyState(
              variant: DfEmptyStateVariant.illustrated,
              icon: Icons.build_circle_outlined,
              title: 'Nenhuma manutenção registrada',
              subtitle: 'Toque em Manutenção para registrar a primeira.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final record = records[index];
              final status = MaintenanceDueChecker.check(
                record: record,
                currentOdometerKm: odometer,
              );
              return _MaintenanceTile(record: record, status: status);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.maintenanceForm),
        icon: const Icon(Icons.build_circle_outlined),
        label: const Text('Manutenção'),
      ),
    );
  }
}

class _MaintenanceTile extends ConsumerWidget {
  const _MaintenanceTile({
    required this.record,
    required this.status,
  });

  final MaintenanceEntity record;
  final MaintenanceDueStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DfCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(AppRoutes.maintenanceForm, extra: record),
        onLongPress: () => _confirmDelete(context, ref),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(record.type.icon, color: _statusColor(status)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(record.type.label, style: theme.textTheme.titleMedium),
                ),
                _StatusChip(status: status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${CurrencyFormatter.format(record.cost)} · '
              '${DateUtilsDriveFlow.dayMonthYear.format(record.serviceDate)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryLabel(theme),
              ),
            ),
            if (record.nextDueKm != null || record.nextDueDate != null) ...[
              const SizedBox(height: 6),
              Text(
                _dueLabel(record),
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (record.notes != null && record.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                record.notes!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _dueLabel(MaintenanceEntity record) {
    final parts = <String>[];
    if (record.nextDueKm != null) {
      parts.add('km ${record.nextDueKm!.toStringAsFixed(0)}');
    }
    if (record.nextDueDate != null) {
      parts.add(DateUtilsDriveFlow.dayMonthYear.format(record.nextDueDate!));
    }
    return 'Próximo: ${parts.join(' · ')}';
  }

  Color _statusColor(MaintenanceDueStatus status) {
    return switch (status) {
      MaintenanceDueStatus.ok => AppColors.profitGreen,
      MaintenanceDueStatus.upcoming => AppColors.warningAmber,
      MaintenanceDueStatus.overdue => AppColors.expenseCoral,
    };
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final MaintenanceDueStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      MaintenanceDueStatus.ok => AppColors.profitGreen,
      MaintenanceDueStatus.upcoming => AppColors.warningAmber,
      MaintenanceDueStatus.overdue => AppColors.expenseCoral,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
