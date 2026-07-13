import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';
import '../providers/shift_history_providers.dart';
import '../widgets/shift_coaching_card.dart';
import '../widgets/shift_shortcuts_card.dart';
import '../widgets/shift_history_tile.dart';

/// Lista de turnos encerrados com exportação CSV.
class ShiftHistoryScreen extends ConsumerWidget {
  const ShiftHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(shiftHistoryStreamProvider);
    final weekStats = ref.watch(shiftHistoryWeekStatsProvider);
    final exportState = ref.watch(shiftHistoryExportControllerProvider);

    return DfSubpageScaffold(
      title: 'Histórico de turnos',
      onRefresh: () async {
        await ref.read(shiftHistoryRepositoryProvider).fetchHistory();
      },
      children: [
        const ShiftCoachingCard(),
        const SizedBox(height: AppSpacing.md),
        const ShiftShortcutsCard(),
        const SizedBox(height: AppSpacing.md),
        DfButton(
          label: 'Analytics de turnos',
          icon: Icons.bar_chart_rounded,
          variant: DfButtonVariant.outlined,
          onPressed: () => context.push(AppRoutes.shiftAnalytics),
        ),
        const SizedBox(height: AppSpacing.md),
        if (weekStats.shiftCount > 0)
          DfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Últimos 7 dias',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${weekStats.shiftCount} turnos · '
                  '${CurrencyFormatter.format(weekStats.revenue)} · '
                  '${weekStats.rides} corridas',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (weekStats.avgAdherence > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Aderência média ${weekStats.avgAdherence.round()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.brandBlue,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ],
            ),
          ),
        DfButton(
          label: 'Exportar CSV',
          icon: Icons.ios_share_rounded,
          variant: DfButtonVariant.tonal,
          isLoading: exportState.isLoading,
          onPressed: exportState.isLoading
              ? null
              : () async {
                  final csv = await ref
                      .read(shiftHistoryExportControllerProvider.notifier)
                      .exportCsv();
                  if (csv == null || !context.mounted) return;
                  final dir = await getTemporaryDirectory();
                  final file = File(
                    '${dir.path}/driveflow-turnos-${DateTime.now().millisecondsSinceEpoch}.csv',
                  );
                  await file.writeAsString(csv);
                  await Share.shareXFiles(
                    [XFile(file.path)],
                    text: 'Histórico de turnos DriveFlow',
                  );
                },
        ),
        const SizedBox(height: AppSpacing.md),
        historyAsync.when(
          loading: () => const DfSkeleton(itemCount: 4),
          error: (_, __) => const DfEmptyState(
            icon: Icons.history_rounded,
            title: 'Não foi possível carregar',
            subtitle: 'Puxe para atualizar.',
          ),
          data: (history) {
            if (history.isEmpty) {
              return DfEmptyState(
                variant: DfEmptyStateVariant.illustrated,
                icon: Icons.history_rounded,
                title: 'Nenhum turno encerrado',
                subtitle:
                    'Finalize um turno no Modo turno para ver a retrospectiva.',
                actionLabel: 'Iniciar turno',
                onAction: () => context.push(AppRoutes.shiftMode),
              );
            }

            return DfCard(
              child: Column(
                children: [
                  for (var i = 0; i < history.length; i++) ...[
                    ShiftHistoryTile(
                      entry: history[i],
                      onTap: () => context.push(
                        '${AppRoutes.shiftRetrospective}?id=${history[i].id}',
                      ),
                    ),
                    if (i < history.length - 1)
                      Divider(
                        height: 1,
                        color: Theme.of(context).dividerColor.withValues(
                              alpha: 0.35,
                            ),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
