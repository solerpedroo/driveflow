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
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/domain/models/dashboard_snapshot.dart';
import '../../../../shared/widgets/design_system/df_expandable_list_section.dart';
import '../../../../shared/widgets/design_system/df_section_header.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_tab_scroll_view.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../providers/dashboard_providers.dart';
import '../../../integrations/presentation/widgets/dashboard_platform_mix_card.dart';
import '../../../integrations/presentation/widgets/dashboard_platform_chip.dart';
import '../widgets/dashboard_editorial_header.dart';
import '../widgets/dashboard_fuel_card.dart';
import '../widgets/dashboard_maintenance_card.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/dashboard_wealth_stage.dart';
import '../../../integrations/presentation/widgets/platform_goal_progress_card.dart';
import '../widgets/month_summary_card.dart';
import '../widgets/weekly_profit_chart.dart';

/// Início minimalista — saudação, um KPI, ações leves.
class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  static String _greeting(int hour, String name) {
    final first = name.split(RegExp(r'\s+')).first;
    final capitalized = first.isEmpty
        ? 'motorista'
        : '${first[0].toUpperCase()}${first.substring(1)}';
    if (hour < 12) return 'Bom dia, $capitalized';
    if (hour < 18) return 'Boa tarde, $capitalized';
    return 'Boa noite, $capitalized';
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
    final isTaxiDriver = ref.watch(isTaxiDriverProvider);

    final displayName = user?.displayName ?? 'motorista';
    final greeting = useMemoized(
      () => _greeting(DateTime.now().hour, displayName),
      [displayName],
    );

    void toggleVisibility() =>
        ref.read(valueVisibilityHiddenProvider.notifier).state = !hidden;

    return dashboardAsync.when(
      loading: () => _DashboardLoading(greeting: greeting),
      error: (_, __) => _DashboardError(
        greeting: greeting,
        onRetry: () => ref.invalidate(dashboardSnapshotProvider),
      ),
      data: (snapshot) => dailyGoal.when(
        data: (goal) => _DashboardBody(
          greeting: greeting,
          hidden: hidden,
          isTaxiDriver: isTaxiDriver,
          onToggleVisibility: toggleVisibility,
          snapshot: snapshot,
          goal: goal,
          vehicle: vehicle,
          lastFuel: lastFuel,
          maintenanceAlerts: maintenanceAlerts,
          topSlots: topSlots,
          topPrediction: topPrediction,
        ),
        loading: () => _DashboardLoading(greeting: greeting),
        error: (_, __) => _DashboardBody(
          greeting: greeting,
          hidden: hidden,
          isTaxiDriver: isTaxiDriver,
          onToggleVisibility: toggleVisibility,
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

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading({required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    return DfTabScrollView(
      children: [
        const DashboardBrandBar(),
        DashboardGreeting(text: greeting),
        const DfSkeleton(itemCount: 2),
      ],
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({
    required this.greeting,
    required this.onRetry,
  });

  final String greeting;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return DfTabScrollView(
      children: [
        const DashboardBrandBar(),
        DashboardGreeting(text: greeting),
        Text(
          'Não foi possível carregar. Tente de novo.',
          style: AppTypography.iosBody(brightness).copyWith(
            color: AppColors.secondaryLabel(Theme.of(context)),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ),
      ],
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.greeting,
    required this.hidden,
    required this.isTaxiDriver,
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
  final bool isTaxiDriver;
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
    final month = snapshot.month;
    final today = snapshot.today;

    return DfTabScrollView(
      children: [
        const DashboardBrandBar(),
        DashboardGreeting(text: greeting),
        DashboardWealthStage(
          month: month,
          today: today,
          goal: goal,
          hideValue: hidden,
          onToggleVisibility: onToggleVisibility,
        ),
        DashboardQuickActions(
          actions: [
            DashboardQuickAction(
              icon: Icons.add_rounded,
              label: 'Ganho',
              onTap: () => context.push(AppRoutes.earningForm),
            ),
            DashboardQuickAction(
              icon: Icons.receipt_long_rounded,
              label: 'Despesa',
              onTap: () => context.push(AppRoutes.expenseForm),
            ),
            DashboardQuickAction(
              icon: Icons.insights_rounded,
              label: 'Relatório',
              onTap: () => context.go('${AppRoutes.home}?tab=reports'),
            ),
            if (isTaxiDriver)
              DashboardQuickAction(
                icon: Icons.flag_rounded,
                label: 'Metas',
                onTap: () => context.push(AppRoutes.goals),
              )
            else
              DashboardQuickAction(
                icon: Icons.hub_rounded,
                label: 'Apps',
                onTap: () => context.push(AppRoutes.platformIntegrations),
              ),
          ],
        ),
        if (!isTaxiDriver) ...[
          const DashboardPlatformChip(),
          const PlatformGoalProgressCard(),
        ],
        const Align(
          alignment: Alignment.centerLeft,
          child: VehicleScopeChip(),
        ),
        if (!isTaxiDriver)
          const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DfSectionHeader(
                title: 'Onde você rodou',
                eyebrow: 'Hoje',
              ),
              SizedBox(height: AppSpacing.md),
              DashboardPlatformMixCard(),
            ],
          ),
        WeeklyProfitChart(points: snapshot.weekProfits),
        MonthSummaryCard(summary: month, hideHeroProfit: true),
        if (topSlots.isNotEmpty || topPrediction != null)
          DashboardInsightsSummary(
            topSlots: topSlots,
            topPrediction: topPrediction,
          ),
        DfExpandableListSection(
          title: 'Seu carro',
          eyebrow: 'Cuidados',
          itemCount: 2,
          previewCount: 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return DashboardFuelCard(vehicle: vehicle, lastFuel: lastFuel);
            }
            return DashboardMaintenanceCard(alerts: maintenanceAlerts);
          },
        ),
      ],
    );
  }
}
