import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../goals/domain/entities/goal_entity.dart';
import '../../../goals/domain/services/goal_progress_calculator.dart';
import '../../../goals/presentation/providers/goals_providers.dart';
import '../../../fuel/domain/entities/fuel_log_entity.dart';
import '../../../fuel/presentation/providers/fuel_providers.dart';
import '../../../insights/domain/entities/earning_time_slot.dart';
import '../../../insights/domain/entities/maintenance_prediction.dart';
import '../../../insights/presentation/providers/insights_providers.dart';
import '../../../insights/presentation/widgets/dashboard_insights_summary.dart';
import '../../../maintenance/presentation/providers/maintenance_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../vehicle/domain/entities/vehicle_entity.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../../vehicle/presentation/widgets/vehicle_scope_chip.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/domain/models/dashboard_snapshot.dart';
import '../../../../shared/widgets/design_system/df_expandable_list_section.dart';
import '../../../../shared/widgets/design_system/df_header_row.dart';
import '../../../../shared/widgets/design_system/df_hero_wealth_card.dart';
import '../../../../shared/widgets/design_system/df_pill_action_button.dart';
import '../../../../shared/widgets/design_system/df_section_header.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_tab_scroll_view.dart';
import '../providers/dashboard_providers.dart';
import '../../../integrations/presentation/widgets/dashboard_platform_mix_card.dart';
import '../../../integrations/presentation/widgets/dashboard_platform_chip.dart';
import '../widgets/dashboard_fuel_card.dart';
import '../widgets/dashboard_maintenance_card.dart';
import '../../../integrations/presentation/widgets/platform_goal_progress_card.dart';
import '../widgets/dashboard_hero_section.dart';
import '../widgets/dashboard_upgrade_banner.dart';
import '../widgets/month_summary_card.dart';
import '../widgets/weekly_profit_chart.dart';

/// Dashboard reorganizado no padrão Mescla Início — hero, resumos, seções.
class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  static String _greetingCaps(int hour, String name) {
    final first = name.split(RegExp(r'\s+')).first.toUpperCase();
    if (hour < 12) return 'BOM DIA, $first';
    if (hour < 18) return 'BOA TARDE, $first';
    return 'BOA NOITE, $first';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider).valueOrNull ??
        ref.watch(authStateProvider).valueOrNull;
    final vehicle = ref.watch(activeVehicleProvider).valueOrNull;
    final lastFuel = ref.watch(lastFuelLogProvider).valueOrNull;
    final maintenanceAlerts =
        ref.watch(maintenanceAlertsProvider).valueOrNull ?? const [];
    final dashboardAsync = ref.watch(dashboardSnapshotProvider);
    final dailyGoal = ref.watch(goalProgressProvider(GoalPeriod.daily));
    final topSlots = ref.watch(topEarningSlotsProvider).valueOrNull ?? const [];
    final topPrediction =
        ref.watch(topMaintenancePredictionProvider).valueOrNull;
    final hidden = ref.watch(valueVisibilityHiddenProvider);

    final displayName = user?.displayName ?? 'motorista';
    final greeting = useMemoized(
      () => _greetingCaps(DateTime.now().hour, displayName),
      [displayName],
    );

    return dashboardAsync.when(
      loading: () => const Center(child: DfSkeleton(itemCount: 4)),
      error: (e, _) => Center(child: Text('Erro ao carregar dashboard: $e')),
      data: (snapshot) => dailyGoal.when(
        data: (goal) => _DashboardBody(
          greeting: greeting,
          hidden: hidden,
          onToggleVisibility: () => ref
              .read(valueVisibilityHiddenProvider.notifier)
              .state = !hidden,
          snapshot: snapshot,
          goal: goal,
          vehicle: vehicle,
          lastFuel: lastFuel,
          maintenanceAlerts: maintenanceAlerts,
          topSlots: topSlots,
          topPrediction: topPrediction,
        ),
        loading: () => const Center(child: DfSkeleton(itemCount: 4)),
        error: (_, __) => _DashboardBody(
          greeting: greeting,
          hidden: hidden,
          onToggleVisibility: () => ref
              .read(valueVisibilityHiddenProvider.notifier)
              .state = !hidden,
          snapshot: snapshot,
          goal: GoalProgressCalculator.calculate(
            period: GoalPeriod.daily,
            goals: null,
            earningsTotal: snapshot.today.revenue,
            expensesTotal: snapshot.today.expenses,
          ),
          vehicle: vehicle,
          lastFuel: lastFuel,
          maintenanceAlerts: maintenanceAlerts,
          topSlots: topSlots,
          topPrediction: topPrediction,
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.greeting,
    required this.hidden,
    required this.onToggleVisibility,
    required this.snapshot,
    required this.goal,
    required this.vehicle,
    required this.lastFuel,
    required this.maintenanceAlerts,
    required this.topSlots,
    required this.topPrediction,
  });

  final String greeting;
  final bool hidden;
  final VoidCallback onToggleVisibility;
  final DashboardSnapshot snapshot;
  final GoalProgress goal;
  final VehicleEntity? vehicle;
  final FuelLogEntity? lastFuel;
  final List<MaintenanceAlert> maintenanceAlerts;
  final List<EarningTimeSlot> topSlots;
  final MaintenancePrediction? topPrediction;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final month = snapshot.month;
    final today = snapshot.today;
    final profitBadge = goal.hasTarget
        ? 'Meta ${goal.progressLabel}'
        : '${today.rides} corridas hoje';

    return DfTabScrollView(
      children: [
        const DfHeaderRow(),
        Text(greeting, style: AppTypography.labelCaps(brightness)),
        DfScreenTitleRow(
          title: 'Seu painel financeiro',
          hidden: hidden,
          onToggleVisibility: onToggleVisibility,
        ),
        DfHeroWealthCard(
          label: 'Lucro do mês',
          value: CurrencyFormatter.formatSigned(month.profit),
          badge: profitBadge,
          hideValue: hidden,
          footer: Row(
            children: [
              Expanded(
                child: _HeroMiniStat(
                  label: 'Ganhos',
                  value: maskCurrency(
                    CurrencyFormatter.format(month.revenue),
                    hidden: hidden,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _HeroMiniStat(
                  label: 'Despesas',
                  value: maskCurrency(
                    CurrencyFormatter.format(month.expenses),
                    hidden: hidden,
                  ),
                ),
              ),
            ],
          ),
        ),
        DashboardHeroSection(
          summary: today,
          goalProgress: goal,
          weekProfits: snapshot.weekProfits,
          hideValue: hidden,
        ),
        const DashboardPlatformChip(),
        const PlatformGoalProgressCard(),
        const Align(
          alignment: Alignment.centerLeft,
          child: VehicleScopeChip(),
        ),
        DfPillActionGrid(
          actions: [
            DfPillActionButton(
              icon: Icons.add_circle_outline,
              label: 'Novo ganho',
              onTap: () => context.push(AppRoutes.earningForm),
            ),
            DfPillActionButton(
              icon: Icons.receipt_long_outlined,
              label: 'Nova despesa',
              onTap: () => context.push(AppRoutes.expenseForm),
            ),
            DfPillActionButton(
              icon: Icons.bar_chart_rounded,
              label: 'Relatórios',
              onTap: () => context.go('${AppRoutes.home}?tab=reports'),
            ),
            DfPillActionButton(
              icon: Icons.hub_outlined,
              label: 'Integrações',
              onTap: () => context.push(AppRoutes.platformIntegrations),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DfSectionHeader(
              title: 'Mix de plataformas',
              eyebrow: 'Hoje',
            ),
            const SizedBox(height: AppSpacing.md),
            const DashboardPlatformMixCard(),
          ],
        ),
        WeeklyProfitChart(points: snapshot.weekProfits),
        MonthSummaryCard(summary: month),
        if (topSlots.isNotEmpty || topPrediction != null)
          DashboardInsightsSummary(
            topSlots: topSlots,
            topPrediction: topPrediction,
          ),
        DfExpandableListSection(
          title: 'Operação do veículo',
          eyebrow: 'Manutenção',
          itemCount: 2,
          previewCount: 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return DashboardFuelCard(vehicle: vehicle, lastFuel: lastFuel);
            }
            return DashboardMaintenanceCard(alerts: maintenanceAlerts);
          },
        ),
        const DashboardUpgradeBanner(),
      ],
    );
  }
}

class _HeroMiniStat extends StatelessWidget {
  const _HeroMiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
