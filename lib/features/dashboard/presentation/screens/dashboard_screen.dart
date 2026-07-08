import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
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
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../maintenance/domain/entities/maintenance_entity.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../shared/widgets/driveflow_brand_logo.dart';
import '../../../../shared/widgets/driveflow_glass_card.dart';
import '../../../../shared/widgets/driveflow_metric_chip.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_today_card.dart';
import '../widgets/month_summary_card.dart';
import '../widgets/weekly_profit_chart.dart';

/// Dashboard — visão consolidada do motorista.
class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(userProfileProvider).valueOrNull ??
        ref.watch(authStateProvider).valueOrNull;
    final vehicle = ref.watch(activeVehicleProvider).valueOrNull;
    final lastFuel = ref.watch(lastFuelLogProvider).valueOrNull;
    final maintenanceAlerts =
        ref.watch(maintenanceAlertsProvider).valueOrNull ?? const [];
    final dailyGoal = ref.watch(goalProgressProvider(GoalPeriod.daily));
    final dashboardAsync = ref.watch(dashboardSnapshotProvider);
    final topSlots = ref.watch(topEarningSlotsProvider).valueOrNull ?? const [];
    final topPrediction = ref.watch(topMaintenancePredictionProvider).valueOrNull;
    final pulse = useAnimationController(
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    final glow = useAnimation(
      CurvedAnimation(parent: pulse, curve: Curves.easeInOut),
    );

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                const Expanded(child: DriveFlowBrandLogo(size: LogoSize.medium)),
                if (user != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      avatar: CircleAvatar(
                        backgroundColor:
                            AppColors.electricTeal.withValues(alpha: 0.2),
                        child: Text(
                          user.displayName.characters.first.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.electricTeal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      label: Text(user.displayName),
                    ),
                  ),
                IconButton.filledTonal(
                  tooltip: 'Alternar tema',
                  onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          sliver: SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.centerLeft,
              child: VehicleScopeChip(),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
          sliver: SliverToBoxAdapter(
            child: DriveFlowGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _PulseDot(animation: glow),
                      const SizedBox(width: 8),
                      Text(
                        'COCKPIT ATIVO',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.electricTeal,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Olá, ${user?.displayName ?? 'motorista'}!',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vehicle != null
                        ? '${vehicle.displayName} · ${vehicle.odometerKm.toStringAsFixed(0)} km'
                        : 'Cadastre seu veículo para liberar métricas completas.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryLabel(theme),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => context.push(AppRoutes.analytics),
                    icon: const Icon(Icons.insights_outlined),
                    label: const Text('Análises'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => context.push(AppRoutes.insights),
                    icon: const Icon(Icons.auto_awesome_outlined),
                    label: const Text('Insights'),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (topSlots.isNotEmpty || topPrediction != null)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            sliver: SliverToBoxAdapter(
              child: DashboardInsightsSummary(
                topSlots: topSlots,
                topPrediction: topPrediction,
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: SliverToBoxAdapter(
            child: dashboardAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (snapshot) => WeeklyProfitChart(points: snapshot.weekProfits),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: SliverToBoxAdapter(
            child: dashboardAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (snapshot) => MonthSummaryCard(summary: snapshot.month),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: SliverToBoxAdapter(
            child: DriveFlowGlassCard(
              onTap: vehicle != null
                  ? () => context.push(AppRoutes.fuelHistory)
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_gas_station_rounded,
                          color: AppColors.infoBlue),
                      const SizedBox(width: 8),
                      Text('Último abastecimento',
                          style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (lastFuel == null)
                    Text(
                      vehicle == null
                          ? 'Cadastre um veículo para registrar combustível.'
                          : 'Nenhum abastecimento ainda. Toque para registrar.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryLabel(theme),
                      ),
                    )
                  else ...[
                    Text(
                      lastFuel.station?.isNotEmpty == true
                          ? lastFuel.station!
                          : lastFuel.fuelType.label,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${CurrencyFormatter.format(lastFuel.totalAmount)} · '
                      '${lastFuel.liters.toStringAsFixed(1)} L · '
                      '${lastFuel.odometerKm.toStringAsFixed(0)} km',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryLabel(theme),
                      ),
                    ),
                    if (lastFuel.hasMetrics) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${lastFuel.kmPerLiter!.toStringAsFixed(1)} km/L · '
                        '${CurrencyFormatter.format(lastFuel.costPerKm!)}/km',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.electricTeal,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
        if (maintenanceAlerts.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            sliver: SliverToBoxAdapter(
              child: DriveFlowGlassCard(
                onTap: () => context.push(AppRoutes.maintenanceHistory),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.build_circle_outlined,
                            color: AppColors.warningAmber),
                        const SizedBox(width: 8),
                        Text('Manutenção pendente',
                            style: theme.textTheme.titleMedium),
                        const Spacer(),
                        Badge(
                          label: Text('${maintenanceAlerts.length}'),
                          backgroundColor: AppColors.expenseCoral,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      maintenanceAlerts.first.record.type.label,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      maintenanceAlerts.first.status.label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: maintenanceAlerts.first.status ==
                                MaintenanceDueStatus.overdue
                            ? AppColors.expenseCoral
                            : AppColors.warningAmber,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: SliverToBoxAdapter(
            child: Text('Métricas de hoje', style: theme.textTheme.titleMedium),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          sliver: SliverToBoxAdapter(
            child: dashboardAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
              data: (snapshot) {
                final today = snapshot.today;
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.65,
                  children: [
                    DriveFlowMetricChip(
                      label: 'Lucro hoje',
                      value: CurrencyFormatter.formatSigned(today.profit),
                      accentColor: today.profit >= 0
                          ? AppColors.profitGreen
                          : AppColors.expenseCoral,
                      icon: Icons.trending_up_rounded,
                    ),
                    DriveFlowMetricChip(
                      label: 'Custo / km',
                      value: today.avgCostPerKm != null
                          ? CurrencyFormatter.format(today.avgCostPerKm!)
                          : '—',
                      accentColor: AppColors.expenseCoral,
                      icon: Icons.route_rounded,
                    ),
                    DriveFlowMetricChip(
                      label: 'Horas',
                      value: DurationFormatter.formatWorkedHours(
                        today.workedHours,
                      ),
                      accentColor: AppColors.infoBlue,
                      icon: Icons.schedule_rounded,
                    ),
                    DriveFlowMetricChip(
                      label: 'Meta diária',
                      value: dailyGoal.when(
                        data: (p) => p.progressLabel,
                        loading: () => '…',
                        error: (_, __) => '—',
                      ),
                      accentColor: dailyGoal.when(
                        data: (p) => p.isComplete
                            ? AppColors.profitGreen
                            : AppColors.warningAmber,
                        loading: () => AppColors.warningAmber,
                        error: (_, __) => AppColors.warningAmber,
                      ),
                      icon: Icons.flag_rounded,
                      onTap: () => context.push(AppRoutes.goals),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot({required this.animation});

  final double animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.electricTeal.withValues(alpha: 0.5 + animation * 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricTeal.withValues(alpha: 0.35 + animation * 0.25),
            blurRadius: 8 + animation * 6,
          ),
        ],
      ),
    );
  }
}
