import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../insights/presentation/providers/insights_providers.dart';
import '../../../insights/presentation/widgets/dashboard_insights_summary.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../../../goals/domain/services/goal_progress_calculator.dart';
import '../../../goals/presentation/providers/goals_providers.dart';
import '../../../fuel/presentation/providers/fuel_providers.dart';
import '../../../maintenance/presentation/providers/maintenance_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../../vehicle/presentation/widgets/vehicle_scope_chip.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_cockpit_card.dart';
import '../widgets/dashboard_fuel_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_maintenance_card.dart';
import '../widgets/dashboard_shortcuts_row.dart';
import '../widgets/dashboard_today_card.dart';
import '../widgets/dashboard_today_metrics_grid.dart';
import '../widgets/month_summary_card.dart';
import '../widgets/weekly_profit_chart.dart';

/// Dashboard — visão consolidada do motorista.
class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider).valueOrNull ??
        ref.watch(authStateProvider).valueOrNull;
    final vehicle = ref.watch(activeVehicleProvider).valueOrNull;
    final lastFuel = ref.watch(lastFuelLogProvider).valueOrNull;
    final maintenanceAlerts =
        ref.watch(maintenanceAlertsProvider).valueOrNull ?? const [];
    final dailyGoal = ref.watch(goalProgressProvider(GoalPeriod.daily));
    final dashboardAsync = ref.watch(dashboardSnapshotProvider);
    final topSlots = ref.watch(topEarningSlotsProvider).valueOrNull ?? const [];
    final topPrediction =
        ref.watch(topMaintenancePredictionProvider).valueOrNull;

    final pulse = useAnimationController(duration: DriveFlowMotion.pulse)
      ..repeat(reverse: true);
    final glow = useAnimation(
      CurvedAnimation(parent: pulse, curve: DriveFlowMotion.standard),
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: DashboardHeader(user: user)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.md,
            AppSpacing.screenHorizontal,
            0,
          ),
          sliver: const SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.centerLeft,
              child: VehicleScopeChip(),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.xl,
            AppSpacing.screenHorizontal,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: DashboardCockpitCard(
              displayName: user?.displayName ?? 'motorista',
              vehicleLine: vehicle != null
                  ? '${vehicle.displayName} · ${vehicle.odometerKm.toStringAsFixed(0)} km'
                  : 'Cadastre seu veículo para liberar métricas completas.',
              pulseAnimation: glow,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: AppSpacing.md),
            child: DashboardShortcutsRow(),
          ),
        ),
        if (topSlots.isNotEmpty || topPrediction != null)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
              AppSpacing.screenHorizontal,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: DashboardInsightsSummary(
                topSlots: topSlots,
                topPrediction: topPrediction,
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
            AppSpacing.screenHorizontal,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: dashboardAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erro ao carregar dashboard: $e'),
              data: (snapshot) => dailyGoal.when(
                data: (goal) => DashboardTodayCard(
                  summary: snapshot.today,
                  goalProgress: goal,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => DashboardTodayCard(
                  summary: snapshot.today,
                  goalProgress: GoalProgressCalculator.calculate(
                    period: GoalPeriod.daily,
                    goals: null,
                    earningsTotal: snapshot.today.revenue,
                    expensesTotal: snapshot.today.expenses,
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
            AppSpacing.screenHorizontal,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: dashboardAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (snapshot) =>
                  WeeklyProfitChart(points: snapshot.weekProfits),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
            AppSpacing.screenHorizontal,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: dashboardAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (snapshot) => MonthSummaryCard(summary: snapshot.month),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
            AppSpacing.screenHorizontal,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: DashboardFuelCard(vehicle: vehicle, lastFuel: lastFuel),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
            AppSpacing.screenHorizontal,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: DashboardMaintenanceCard(alerts: maintenanceAlerts),
          ),
        ),
        SliverToBoxAdapter(
          child: dashboardAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (snapshot) =>
                DashboardTodayMetricsGrid(today: snapshot.today),
          ),
        ),
      ],
    );
  }
}
