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
import '../../../../shared/widgets/design_system/df_hero_wealth_card.dart';
import '../../../../shared/widgets/design_system/df_pill_action_button.dart';
import '../../../../shared/widgets/design_system/df_screen_body.dart';
import '../../../../shared/widgets/design_system/df_section_header.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_staggered_entrance.dart';
import '../../../../shared/widgets/design_system/df_tab_scroll_view.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../providers/dashboard_providers.dart';
import '../../../integrations/presentation/widgets/dashboard_platform_mix_card.dart';
import '../../../integrations/presentation/widgets/dashboard_platform_chip.dart';
import '../widgets/dashboard_editorial_header.dart';
import '../widgets/dashboard_fuel_card.dart';
import '../widgets/dashboard_maintenance_card.dart';
import '../../../integrations/presentation/widgets/platform_goal_progress_card.dart';
import '../widgets/dashboard_hero_section.dart';
import '../widgets/month_summary_card.dart';
import '../widgets/weekly_profit_chart.dart';

/// Início — composição editorial (auth-level) + um KPI dominante.
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

  static String _subtitle({
    required bool hidden,
    required double monthProfit,
    required int todayRides,
  }) {
    if (hidden) {
      return 'Valores ocultos. Toque no olho para revelar o mês e o dia.';
    }
    if (todayRides == 0 && monthProfit == 0) {
      return 'Registre o primeiro ganho e o painel ganha vida.';
    }
    if (monthProfit >= 0) {
      return 'Mês no azul. Confira o dia e as próximas ações abaixo.';
    }
    return 'Mês apertado — olhe o dia e ajuste ganhos e gastos.';
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
      loading: () => _DashboardLoading(greeting: greeting, hidden: hidden),
      error: (_, __) => _DashboardError(
        greeting: greeting,
        hidden: hidden,
        onToggleVisibility: toggleVisibility,
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
        loading: () => _DashboardLoading(greeting: greeting, hidden: hidden),
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
  const _DashboardLoading({
    required this.greeting,
    required this.hidden,
  });

  final String greeting;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return DfTabScrollView(
      children: [
        DashboardEditorialHeader(
          greeting: greeting,
          subtitle: 'Carregando seu resumo…',
          hidden: hidden,
          onToggleVisibility: () {},
        ),
        const DfSkeleton(itemCount: 3),
      ],
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({
    required this.greeting,
    required this.hidden,
    required this.onToggleVisibility,
    required this.onRetry,
  });

  final String greeting;
  final bool hidden;
  final VoidCallback onToggleVisibility;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return DfTabScrollView(
      children: [
        DashboardEditorialHeader(
          greeting: greeting,
          subtitle: 'Não foi possível carregar o resumo agora.',
          hidden: hidden,
          onToggleVisibility: onToggleVisibility,
        ),
        Text(
          'Verifique a conexão e tente de novo. Seus dados continuam salvos.',
          style: AppTypography.iosBody(brightness).copyWith(
            color: AppColors.secondaryLabel(Theme.of(context)),
            height: 1.45,
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
    final profitBadge = goal.hasTarget
        ? 'Meta ${goal.progressLabel}'
        : '${today.rides} corridas hoje';
    final subtitle = DashboardScreen._subtitle(
      hidden: hidden,
      monthProfit: month.profit,
      todayRides: today.rides,
    );

    return DfTabScrollView(
      children: [
        DfStaggeredEntrance(
          children: [
            DashboardEditorialHeader(
              greeting: greeting,
              subtitle: subtitle,
              hidden: hidden,
              onToggleVisibility: onToggleVisibility,
            ),
            const SizedBox(height: DfScreenBody.sectionGap),
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
            const SizedBox(height: DfScreenBody.sectionGap),
            DashboardHeroSection(
              summary: today,
              goalProgress: goal,
              weekProfits: snapshot.weekProfits,
              hideValue: hidden,
            ),
            const SizedBox(height: DfScreenBody.sectionGap),
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
                if (isTaxiDriver)
                  DfPillActionButton(
                    icon: Icons.flag_outlined,
                    label: 'Metas',
                    onTap: () => context.push(AppRoutes.goals),
                  )
                else
                  DfPillActionButton(
                    icon: Icons.hub_outlined,
                    label: 'Conectar apps',
                    onTap: () => context.push(AppRoutes.platformIntegrations),
                  ),
              ],
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
                title: 'Onde você rodou hoje',
                eyebrow: 'Apps',
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
          eyebrow: 'Combustível e revisão',
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

class _HeroMiniStat extends StatelessWidget {
  const _HeroMiniStat({required this.label, required this.value});

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
            color: Colors.white.withValues(alpha: 0.70),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
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
