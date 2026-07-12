import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_expandable_list_section.dart';
import '../../../../shared/widgets/design_system/df_hero_wealth_card.dart';
import '../../../../shared/widgets/design_system/df_movimentacao_tile.dart';
import '../../../../shared/widgets/design_system/df_quick_actions.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../../domain/services/maintenance_due_checker.dart';
import '../providers/maintenance_providers.dart';

/// Histórico de manutenções — DNA Início / Perfil.
class MaintenanceHistoryScreen extends ConsumerWidget {
  const MaintenanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(activeVehicleMaintenanceProvider);
    final odometer =
        ref.watch(activeVehicleProvider).valueOrNull?.odometerKm ?? 0;
    final hidden = ref.watch(valueVisibilityHiddenProvider);
    final records = recordsAsync.valueOrNull;
    final totalCost =
        records?.fold<double>(0, (sum, r) => sum + r.cost) ?? 0;

    return DfSubpageScaffold(
      title: 'Manutenções',
      children: [
        DfHeroWealthCard(
          label: 'Total investido',
          value: CurrencyFormatter.format(totalCost),
          badge: '${records?.length ?? 0} serviços',
          hideValue: hidden,
          onToggleVisibility: () => ref
              .read(valueVisibilityHiddenProvider.notifier)
              .state = !hidden,
          footer: Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: 'Serviços',
                  value: hidden ? '•••' : '${records?.length ?? 0}',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _HeroStat(
                  label: 'Odômetro',
                  value: hidden
                      ? '•••'
                      : '${odometer.toStringAsFixed(0)} km',
                ),
              ),
            ],
          ),
        ),
        DfQuickActions(
          actions: [
            DfQuickAction(
              icon: Icons.build_circle_outlined,
              label: 'Registrar',
              onTap: () => context.push(AppRoutes.maintenanceForm),
            ),
            DfQuickAction(
              icon: Icons.local_gas_station_rounded,
              label: 'Combustível',
              onTap: () => context.push(AppRoutes.fuelHistory),
            ),
            DfQuickAction(
              icon: Icons.auto_awesome_rounded,
              label: 'Insights',
              onTap: () => context.push(AppRoutes.insights),
            ),
            DfQuickAction(
              icon: Icons.person_rounded,
              label: 'Perfil',
              onTap: () => context.go('${AppRoutes.home}?tab=profile'),
            ),
          ],
        ),
        recordsAsync.when(
          loading: () => const DfSkeleton(itemCount: 3),
          error: (e, _) => Text(
            'Não foi possível carregar. Tente novamente.',
            style: AppTypography.iosBody(Theme.of(context).brightness).copyWith(
              color: AppColors.secondaryLabel(Theme.of(context)),
            ),
          ),
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
              spacing: AppSpacing.md,
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

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.iosFootnote(brightness).copyWith(
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.iosHeadline(brightness).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
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
