import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../goals/domain/entities/goal_entity.dart';
import '../../../goals/presentation/providers/goals_providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../shared/domain/models/period_summary.dart';
import '../../../../shared/widgets/design_system/df_chip.dart';
import '../../../../shared/widgets/design_system/df_section_header.dart';

/// Grid de métricas do dia no dashboard.
class DashboardTodayMetricsGrid extends ConsumerWidget {
  const DashboardTodayMetricsGrid({
    required this.today,
    super.key,
  });

  final PeriodSummary today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyGoal = ref.watch(goalProgressProvider(GoalPeriod.daily));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: DfSectionHeader(title: 'Métricas de hoje'),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            0,
            AppSpacing.screenHorizontal,
            AppSpacing.xxl,
          ),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.65,
            children: [
              DfChip(
                label: 'Lucro hoje',
                value: CurrencyFormatter.formatSigned(today.profit),
                accentColor: today.profit >= 0
                    ? AppColors.profitGreen
                    : AppColors.expenseCoral,
                icon: Icons.trending_up_rounded,
              ),
              DfChip(
                label: 'Custo / km',
                value: today.avgCostPerKm != null
                    ? CurrencyFormatter.format(today.avgCostPerKm!)
                    : '—',
                accentColor: AppColors.expenseCoral,
                icon: Icons.route_rounded,
              ),
              DfChip(
                label: 'Horas',
                value: DurationFormatter.formatWorkedHours(today.workedHours),
                accentColor: AppColors.infoBlue,
                icon: Icons.schedule_rounded,
              ),
              DfChip(
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
          ),
        ),
      ],
    );
  }
}
