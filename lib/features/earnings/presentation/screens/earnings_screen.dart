import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/date_range_period.dart';
import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_expandable_list_section.dart';
import '../../../../shared/widgets/design_system/df_filter_pill.dart';
import '../../../../shared/widgets/design_system/df_header_row.dart';
import '../../../../shared/widgets/design_system/df_hero_wealth_card.dart';
import '../../../../shared/widgets/design_system/df_quick_actions.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_tab_scroll_view.dart';
import '../../../../shared/widgets/driveflow_period_filter.dart';
import '../../../../shared/widgets/platform_brand_icon.dart';
import '../../domain/entities/earning_entity.dart';
import '../providers/earnings_providers.dart';
import '../widgets/earning_tile.dart';
import '../widgets/quick_earning_sheet.dart';

/// Ganhos — mesmo DNA da Início (hero + ações + módulos elevados).
class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  static void _toggleVisibility(WidgetRef ref, bool hidden) {
    ref.read(valueVisibilityHiddenProvider.notifier).state = !hidden;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(earningsPeriodProvider);
    final platformFilter = ref.watch(earningsPlatformFilterProvider);
    final earningsAsync = ref.watch(earningsListProvider);
    final totalAsync = ref.watch(earningsTotalProvider);
    final hidden = ref.watch(valueVisibilityHiddenProvider);
    final isTaxiDriver = ref.watch(isTaxiDriverProvider);
    final driverType = ref.watch(driverTypeProvider);
    final platforms = ridePlatformsFor(driverType);

    return earningsAsync.when(
      loading: () => const DfTabScrollView(
        children: [
          DfHeaderRow(),
          DfScreenTitleRow(title: 'Ganhos'),
          DfSkeleton(itemCount: 4),
        ],
      ),
      error: (e, _) => DfTabScrollView(
        children: [
          const DfHeaderRow(),
          const DfScreenTitleRow(title: 'Ganhos'),
          Text(
            'Não foi possível carregar. Tente novamente.',
            style: AppTypography.iosBody(Theme.of(context).brightness).copyWith(
              color: AppColors.secondaryLabel(Theme.of(context)),
            ),
          ),
        ],
      ),
      data: (earnings) => DfTabScrollView(
        onRefresh: () async {
          await ref.read(earningsRepositoryProvider).fetchEarnings();
        },
        children: [
          const DfHeaderRow(),
          const DfScreenTitleRow(title: 'Ganhos'),
          totalAsync.when(
            loading: () => const SizedBox(
              height: 140,
              child: DfSkeleton(itemCount: 1),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (total) => _EarningsHero(
              total: total,
              earnings: earnings,
              hideValue: hidden,
              onToggleVisibility: () => _toggleVisibility(ref, hidden),
            ),
          ),
          DfQuickActions(
            actions: [
              DfQuickAction(
                icon: Icons.bolt_rounded,
                label: 'Ganho',
                onTap: () => QuickEarningSheet.show(context),
              ),
              if (!isTaxiDriver)
                DfQuickAction(
                  icon: Icons.hub_rounded,
                  label: 'Apps',
                  onTap: () => context.push(AppRoutes.platformIntegrations),
                ),
              DfQuickAction(
                icon: Icons.flag_rounded,
                label: 'Metas',
                onTap: () => context.push(AppRoutes.goals),
              ),
              DfQuickAction(
                icon: Icons.insights_rounded,
                label: 'Relatório',
                onTap: () => context.go('${AppRoutes.home}?tab=reports'),
              ),
            ],
          ),
          _EarningsFiltersCard(
            period: period,
            platformFilter: platformFilter,
            platforms: platforms,
            onPeriodChanged: (p) =>
                ref.read(earningsPeriodProvider.notifier).state = p,
            onPlatformChanged: (platform) => ref
                .read(earningsPlatformFilterProvider.notifier)
                .state = platform,
          ),
          if (earnings.isEmpty)
            const DfEmptyState(
              variant: DfEmptyStateVariant.illustrated,
              icon: Icons.payments_outlined,
              title: 'Nenhum ganho neste período',
              subtitle:
                  'Toque em Ganho para registrar sua primeira corrida.',
            )
          else
            DfExpandableListSection(
              title: 'Movimentações',
              eyebrow: 'Lista',
              itemCount: earnings.length,
              spacing: AppSpacing.md,
              itemBuilder: (context, index) =>
                  EarningTile(earning: earnings[index], hideValue: hidden),
            ),
        ],
      ),
    );
  }
}

class _EarningsHero extends StatelessWidget {
  const _EarningsHero({
    required this.total,
    required this.earnings,
    required this.hideValue,
    required this.onToggleVisibility,
  });

  final double total;
  final List<EarningEntity> earnings;
  final bool hideValue;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final rides = earnings.fold<int>(0, (sum, e) => sum + e.rides);
    final hours = earnings.fold<double>(0, (sum, e) => sum + e.workedHours);

    return DfHeroWealthCard(
      label: 'Total no período',
      value: CurrencyFormatter.format(total),
      badge: '${earnings.length} registros',
      hideValue: hideValue,
      onToggleVisibility: onToggleVisibility,
      footer: Row(
        children: [
          Expanded(
            child: _HeroStat(
              label: 'Corridas',
              value: hideValue ? '•••' : '$rides',
              brightness: brightness,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _HeroStat(
              label: 'Horas',
              value: hideValue ? '•••' : hours.toStringAsFixed(1),
              brightness: brightness,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.brightness,
  });

  final String label;
  final String value;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
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

class _EarningsFiltersCard extends StatelessWidget {
  const _EarningsFiltersCard({
    required this.period,
    required this.platformFilter,
    required this.platforms,
    required this.onPeriodChanged,
    required this.onPlatformChanged,
  });

  final DateRangePeriod period;
  final RidePlatform? platformFilter;
  final List<RidePlatform> platforms;
  final ValueChanged<DateRangePeriod> onPeriodChanged;
  final ValueChanged<RidePlatform?> onPlatformChanged;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return DfCard(
      variant: DfCardVariant.elevated,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros',
            style: AppTypography.labelCaps(brightness),
          ),
          const SizedBox(height: AppSpacing.md),
          DriveFlowPeriodFilter(
            value: period,
            onChanged: onPeriodChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                DfFilterPill(
                  label: 'Todas',
                  selected: platformFilter == null,
                  accentColor: AppColors.brandBlue,
                  onSelected: () => onPlatformChanged(null),
                ),
                ...platforms.map(
                  (platform) => Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: DfFilterPill(
                      label: platform.label,
                      selected: platformFilter == platform,
                      accentColor: AppColors.brandBlue,
                      leading: PlatformBrandIcon.hasBrandAsset(platform)
                          ? PlatformBrandIcon(
                              platform: platform,
                              size: 20,
                              borderRadius: 6,
                            )
                          : null,
                      onSelected: () => onPlatformChanged(platform),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
