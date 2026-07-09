import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/fuel_log_entity.dart';
import '../providers/fuel_providers.dart';

/// Histórico de abastecimentos com métricas calculadas.
class FuelHistoryScreen extends ConsumerWidget {
  const FuelHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logsAsync = ref.watch(activeVehicleFuelLogsProvider);
    final rollingAvg = ref.watch(rollingKmPerLiterProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Abastecimentos'),
        backgroundColor: Colors.transparent,
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (logs) {
          return CustomScrollView(
            slivers: [
              if (rollingAvg.valueOrNull != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: DfCard(
                      child: Row(
                        children: [
                          const Icon(Icons.speed_rounded,
                              color: AppColors.infoBlue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Média km/L (últimos registros)',
                                    style: theme.textTheme.labelMedium),
                                Text(
                                  '${rollingAvg.value!.toStringAsFixed(1)} km/L',
                                  style: theme.textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (logs.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: DfEmptyState(
                    variant: DfEmptyStateVariant.illustrated,
                    icon: Icons.local_gas_station_outlined,
                    title: 'Nenhum abastecimento registrado',
                    subtitle: 'Toque em Abastecer para registrar o primeiro.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
                  sliver: SliverList.separated(
                    itemCount: logs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _FuelLogTile(log: logs[index]);
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.fuelLog),
        icon: const Icon(Icons.local_gas_station_rounded),
        label: const Text('Abastecer'),
      ),
    );
  }
}

class _FuelLogTile extends ConsumerWidget {
  const _FuelLogTile({required this.log});

  final FuelLogEntity log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final title = log.station?.isNotEmpty == true
        ? log.station!
        : log.fuelType.label;

    return DfCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(AppRoutes.fuelLog, extra: log),
        onLongPress: () => _confirmDelete(context, ref),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                Text(
                  CurrencyFormatter.format(log.totalAmount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.expenseCoral,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${log.liters.toStringAsFixed(1)} L · '
              'R\$ ${log.pricePerLiter.toStringAsFixed(2)}/L · '
              '${log.odometerKm.toStringAsFixed(0)} km',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryLabel(theme),
              ),
            ),
            if (log.createdAt != null) ...[
              const SizedBox(height: 2),
              Text(
                DateUtilsDriveFlow.dateTime.format(log.createdAt!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryLabel(theme),
                ),
              ),
            ],
            if (log.hasMetrics) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text('${log.kmPerLiter!.toStringAsFixed(1)} km/L'),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text(
                      '${CurrencyFormatter.format(log.costPerKm!)}/km',
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'Métricas disponíveis a partir do 2º abastecimento.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryLabel(theme),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
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
