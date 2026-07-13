import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failure_message.dart';
import '../../../../core/services/shift_notification_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_confirm_dialog.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';
import '../../../earnings/presentation/widgets/quick_earning_sheet.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../domain/entities/shift_session_status.dart';
import '../providers/shift_session_providers.dart';
import '../providers/shift_coaching_providers.dart';
import '../widgets/shift_earnings_summary.dart';
import '../widgets/shift_coaching_card.dart';
import '../widgets/shift_plan_progress_row.dart';
import '../widgets/shift_timer_widget.dart';

/// Tela operacional do modo turno — timer, ganhos e ações.
class ShiftModeScreen extends HookConsumerWidget {
  const ShiftModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeShiftSessionProvider).valueOrNull;
    final summary = ref.watch(shiftSessionSummaryProvider);
    final adherence = ref.watch(shiftPlanAdherenceProvider);
    final mutation = ref.watch(shiftSessionControllerProvider);
    final hidden = ref.watch(valueVisibilityHiddenProvider);
    final isTaxi = ref.watch(isTaxiDriverProvider);
    final plan = ref.watch(adaptiveShiftPlanProvider).valueOrNull;

    final ticker = useState(0);
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 1), (_) {
        ticker.value++;
      });
      return timer.cancel;
    }, const []);
    final _ = ticker.value;

    Future<void> startShift() async {
      DfHaptics.medium();
      final created = await ref.read(shiftSessionControllerProvider.notifier).start(
            plan: plan,
            isTaxiMode: isTaxi,
          );
      if (created == null && context.mounted && mutation.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(FailureMessage.forObject(mutation.error))),
        );
      }
    }

    Future<void> endShift() async {
      final confirm = await DfConfirmDialog.show(
        context: context,
        title: 'Encerrar turno?',
        message:
            'O cronômetro para e os ganhos ficam no histórico do dia.',
        confirmLabel: 'Encerrar',
        cancelLabel: 'Continuar',
      );
      if (confirm != true || !context.mounted) return;

      DfHaptics.medium();
      final endedSummary = ref.read(shiftSessionSummaryProvider);
      final archived =
          await ref.read(shiftSessionControllerProvider.notifier).end();
      if (!context.mounted) return;
      if (archived != null) {
        if (endedSummary != null) {
          await ShiftNotificationService.instance.notifyShiftEnded(
            revenueLabel: CurrencyFormatter.format(endedSummary.revenue),
            elapsedLabel: ShiftTimerWidget.format(endedSummary.elapsed),
          );
        }
        context.go('${AppRoutes.shiftRetrospective}?id=${archived.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turno encerrado. Veja a retrospectiva.')),
        );
      }
    }

    if (session == null) {
      return DfSubpageScaffold(
        title: 'Modo turno',
        children: [
          if (!isTaxi) const ShiftCoachingCard(showStartAction: false),
          if (!isTaxi) const SizedBox(height: AppSpacing.md),
          DfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isTaxi
                      ? 'Acompanhe seu turno com cronômetro e ganhos rápidos.'
                      : 'Usamos seu heatmap para montar um plano de apps '
                          'nas próximas horas.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryLabel(Theme.of(context)),
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                DfButton(
                  label: 'Iniciar turno',
                  icon: Icons.play_arrow_rounded,
                  isLoading: mutation.isLoading,
                  onPressed: mutation.isLoading ? null : startShift,
                ),
                const SizedBox(height: AppSpacing.sm),
                DfButton(
                  label: 'Ver histórico',
                  variant: DfButtonVariant.outlined,
                  icon: Icons.history_rounded,
                  onPressed: () => context.push(AppRoutes.shiftHistory),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final elapsed = session.elapsedAt(DateTime.now());
    final isPaused = session.status == ShiftSessionStatus.paused;

    return DfSubpageScaffold(
      title: 'Turno ativo',
      children: [
        DfCard(
          variant: DfCardVariant.hero,
          child: ShiftTimerWidget(elapsed: elapsed, isPaused: isPaused),
        ),
        const SizedBox(height: AppSpacing.md),
        if (summary != null)
          DfCard(
            child: ShiftEarningsSummary(summary: summary, hideValue: hidden),
          ),
        if (!session.isTaxiMode && session.planBlocks.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          DfCard(child: ShiftPlanProgressRow(adherence: adherence)),
        ],
        const SizedBox(height: AppSpacing.md),
        DfButton(
          label: 'Ganho rápido',
          icon: Icons.bolt_rounded,
          onPressed: () => QuickEarningSheet.show(context),
        ),
        const SizedBox(height: AppSpacing.sm),
        DfButton(
          label: 'Histórico de turnos',
          variant: DfButtonVariant.outlined,
          icon: Icons.history_rounded,
          onPressed: () => context.push(AppRoutes.shiftHistory),
        ),
        const SizedBox(height: AppSpacing.sm),
        DfButton(
          label: isPaused ? 'Retomar' : 'Pausar',
          variant: DfButtonVariant.tonal,
          icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          isLoading: mutation.isLoading,
          onPressed: mutation.isLoading
              ? null
              : () async {
                  DfHaptics.light();
                  if (isPaused) {
                    await ref
                        .read(shiftSessionControllerProvider.notifier)
                        .resume();
                  } else {
                    await ref
                        .read(shiftSessionControllerProvider.notifier)
                        .pause();
                  }
                },
        ),
        const SizedBox(height: AppSpacing.sm),
        DfButton(
          label: 'Encerrar turno',
          variant: DfButtonVariant.outlined,
          icon: Icons.stop_rounded,
          isLoading: mutation.isLoading,
          onPressed: mutation.isLoading ? null : endShift,
        ),
      ],
    );
  }
}
