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
import '../../../../shared/widgets/design_system/df_confirm_dialog.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_expandable_list_section.dart';
import '../../../../shared/widgets/design_system/df_hero_wealth_card.dart';
import '../../../../shared/widgets/design_system/df_movimentacao_tile.dart';
import '../../../../shared/widgets/design_system/df_quick_actions.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';
import '../../domain/entities/fuel_log_entity.dart';
import '../providers/fuel_providers.dart';

/// Histórico de abastecimentos — DNA Início / Perfil.
class FuelHistoryScreen extends ConsumerWidget {
  const FuelHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(activeVehicleFuelLogsProvider);
    final rollingAvg = ref.watch(rollingKmPerLiterProvider);
    final hidden = ref.watch(valueVisibilityHiddenProvider);
    final logs = logsAsync.valueOrNull;
    final totalSpent =
        logs?.fold<double>(0, (sum, log) => sum + log.totalAmount) ?? 0;

    return DfSubpageScaffold(
      title: 'Abastecimentos',
      children: [
        DfHeroWealthCard(
          label: 'Total abastecido',
          value: CurrencyFormatter.format(totalSpent),
          badge: rollingAvg.valueOrNull != null
              ? '${rollingAvg.value!.toStringAsFixed(1)} km/L'
              : '${logs?.length ?? 0} registros',
          hideValue: hidden,
          onToggleVisibility: () => ref
              .read(valueVisibilityHiddenProvider.notifier)
              .state = !hidden,
          footer: Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: 'Registros',
                  value: hidden ? '•••' : '${logs?.length ?? 0}',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _HeroStat(
                  label: 'Média',
                  value: hidden
                      ? '•••'
                      : rollingAvg.valueOrNull != null
                          ? '${rollingAvg.value!.toStringAsFixed(1)} km/L'
                          : '—',
                ),
              ),
            ],
          ),
        ),
        DfQuickActions(
          actions: [
            DfQuickAction(
              icon: Icons.local_gas_station_rounded,
              label: 'Abastecer',
              onTap: () => context.push(AppRoutes.fuelLog),
            ),
            DfQuickAction(
              icon: Icons.receipt_long_rounded,
              label: 'Despesas',
              onTap: () => context.go('${AppRoutes.home}?tab=expenses'),
            ),
            DfQuickAction(
              icon: Icons.insights_rounded,
              label: 'Relatório',
              onTap: () => context.go('${AppRoutes.home}?tab=reports'),
            ),
            DfQuickAction(
              icon: Icons.build_circle_outlined,
              label: 'Manutenção',
              onTap: () => context.push(AppRoutes.maintenanceHistory),
            ),
          ],
        ),
        logsAsync.when(
          loading: () => const DfSkeleton(itemCount: 3),
          error: (e, _) => Text(
            'Não foi possível carregar. Tente novamente.',
            style: AppTypography.iosBody(Theme.of(context).brightness).copyWith(
              color: AppColors.secondaryLabel(Theme.of(context)),
            ),
          ),
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
              spacing: AppSpacing.md,
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
    final confirmed = await DfConfirmDialog.show(
      context: context,
      title: 'Excluir abastecimento?',
      message: 'A despesa de combustível vinculada também será removida.',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (confirmed) {
      await ref.read(fuelControllerProvider.notifier).delete(log.id);
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
    final title =
        log.station?.isNotEmpty == true ? log.station! : log.fuelType.label;

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
