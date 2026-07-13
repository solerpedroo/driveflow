import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/shift_session_status.dart';
import '../providers/shift_session_providers.dart';
import 'shift_earnings_summary.dart';
import 'shift_plan_progress_row.dart';
import 'shift_timer_widget.dart';

/// Hero do dashboard quando não há turno ativo — convite para iniciar.
class DashboardShiftStartCard extends ConsumerWidget {
  const DashboardShiftStartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeShiftSessionProvider).valueOrNull;
    if (session != null) return const SizedBox.shrink();

    final theme = Theme.of(context);

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
            'Modo turno',
            style: AppTypography.labelCaps(theme.brightness),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Cronômetro ao vivo, ganhos da sessão e plano de apps.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryLabel(theme),
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DfButton(
            label: 'Iniciar turno',
            icon: Icons.play_arrow_rounded,
            onPressed: () {
              DfHaptics.medium();
              context.push(AppRoutes.shiftMode);
            },
          ),
        ],
      ),
    );
  }
}

/// Card expandido no dashboard com métricas do turno ativo.
class DashboardActiveShiftCard extends ConsumerWidget {
  const DashboardActiveShiftCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeShiftSessionProvider).valueOrNull;
    final summary = ref.watch(shiftSessionSummaryProvider);
    final adherence = ref.watch(shiftPlanAdherenceProvider);
    final hidden = ref.watch(valueVisibilityHiddenProvider);

    if (session == null || summary == null) return const SizedBox.shrink();

    return DfCard(
      variant: DfCardVariant.hero,
      onTap: () => context.push(AppRoutes.shiftMode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShiftTimerWidget(
            elapsed: summary.elapsed,
            isPaused: session.status == ShiftSessionStatus.paused,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            hidden ? '•••' : CurrencyFormatter.format(summary.revenue),
            style: AppTypography.iosLargeTitle(
              Theme.of(context).brightness,
            ).copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            '${summary.rides} corridas no turno',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryLabel(Theme.of(context)),
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          ShiftEarningsSummary(summary: summary, hideValue: hidden),
          if (!session.isTaxiMode && session.planBlocks.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            ShiftPlanProgressRow(adherence: adherence),
          ],
        ],
      ),
    );
  }
}
