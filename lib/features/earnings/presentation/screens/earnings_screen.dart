import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_expandable_list_section.dart';
import '../../../../shared/widgets/design_system/df_filter_pill.dart';
import '../../../../shared/widgets/design_system/df_header_row.dart';
import '../../../../shared/widgets/design_system/df_hero_wealth_card.dart';
import '../../../../shared/widgets/design_system/df_pill_action_button.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_tab_scroll_view.dart';
import '../../../../shared/widgets/driveflow_period_filter.dart';
import '../providers/earnings_providers.dart';
import '../widgets/earning_tile.dart';

/// Ganhos no padrão Mescla Carteira — hero, ações 2×2, movimentações.
class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(earningsPeriodProvider);
    final platformFilter = ref.watch(earningsPlatformFilterProvider);
    final earningsAsync = ref.watch(earningsListProvider);
    final totalAsync = ref.watch(earningsTotalProvider);
    final hidden = ref.watch(valueVisibilityHiddenProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: earningsAsync.when(
        loading: () => const Center(child: DfSkeleton(itemCount: 4)),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (earnings) => DfTabScrollView(
          onRefresh: () async {
            await ref.read(earningsRepositoryProvider).fetchEarnings();
          },
          children: [
            const DfHeaderRow(),
            DfScreenTitleRow(
              title: 'Ganhos',
              hidden: hidden,
              onToggleVisibility: () => ref
                  .read(valueVisibilityHiddenProvider.notifier)
                  .state = !hidden,
            ),
            totalAsync.when(
              loading: () => const SizedBox(
                height: 140,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (total) => DfHeroWealthCard(
                label: 'Total no período',
                value: CurrencyFormatter.format(total),
                badge: '${earnings.length} registros',
                hideValue: hidden,
              ),
            ),
            DfPillActionGrid(
              actions: [
                DfPillActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'Novo ganho',
                  onTap: () => context.push(AppRoutes.earningForm),
                ),
                DfPillActionButton(
                  icon: Icons.hub_outlined,
                  label: 'Integrações',
                  onTap: () => context.push(AppRoutes.platformIntegrations),
                ),
                DfPillActionButton(
                  icon: Icons.flag_outlined,
                  label: 'Metas',
                  onTap: () => context.push(AppRoutes.goals),
                ),
                DfPillActionButton(
                  icon: Icons.bar_chart_rounded,
                  label: 'Relatórios',
                  onTap: () => context.go('${AppRoutes.home}?tab=reports'),
                ),
              ],
            ),
            DriveFlowPeriodFilter(
              value: period,
              onChanged: (p) =>
                  ref.read(earningsPeriodProvider.notifier).state = p,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  DfFilterPill(
                    label: 'Todas',
                    selected: platformFilter == null,
                    onSelected: () => ref
                        .read(earningsPlatformFilterProvider.notifier)
                        .state = null,
                  ),
                  ...kRidePlatforms.map(
                    (platform) => Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: DfFilterPill(
                        label: platform.label,
                        selected: platformFilter == platform,
                        onSelected: () => ref
                            .read(earningsPlatformFilterProvider.notifier)
                            .state = platform,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (earnings.isEmpty)
              const DfEmptyState(
                variant: DfEmptyStateVariant.illustrated,
                icon: Icons.payments_outlined,
                title: 'Nenhum ganho neste período',
                subtitle:
                    'Toque em Novo ganho para registrar sua primeira corrida.',
              )
            else
              DfExpandableListSection(
                title: 'Minhas movimentações',
                eyebrow: 'Ganhos',
                itemCount: earnings.length,
                itemBuilder: (context, index) =>
                    EarningTile(earning: earnings[index], hideValue: hidden),
              ),
          ],
        ),
      ),
    );
  }
}
