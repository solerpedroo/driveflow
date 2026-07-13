import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/services/shift_automation_service.dart';
import '../../features/integrations/domain/entities/platform_shift_plan.dart';
import '../../features/onboarding/presentation/providers/onboarding_providers.dart';
import '../../features/shift/domain/entities/shift_coach_insight.dart';
import '../../features/shift/domain/services/shift_automation_scheduler.dart';
import '../../features/shift/presentation/providers/shift_coaching_providers.dart';
import '../../features/shift/presentation/providers/shift_session_providers.dart';

/// Sincroniza lembrete automático de pré-turno quando plano/coaching mudam.
///
/// Plano adaptativo + coaching só ficam vivos para motoristas de app,
/// e param de re-sincronizar enquanto há turno ativo.
class ShiftAutomationBootstrap extends ConsumerWidget {
  const ShiftAutomationBootstrap({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTaxi = ref.watch(isTaxiDriverProvider);
    if (isTaxi) return child;

    ref.listen(adaptiveShiftPlanProvider, (previous, next) {
      if (ref.read(activeShiftSessionProvider).valueOrNull != null) return;
      _sync(ref, plan: next.valueOrNull);
    });

    ref.listen(shiftCoachInsightProvider, (previous, next) {
      if (ref.read(activeShiftSessionProvider).valueOrNull != null) return;
      _sync(ref, coaching: next);
    });

    ref.listen(activeShiftSessionProvider, (previous, next) {
      final wasActive = previous?.valueOrNull != null;
      final isActive = next.valueOrNull != null;
      if (isActive) {
        ShiftAutomationService.instance.cancelPreShiftReminder();
      } else if (wasActive && !isActive) {
        _sync(ref);
      }
    });

    return child;
  }

  void _sync(
    WidgetRef ref, {
    PlatformShiftPlan? plan,
    ShiftCoachInsight? coaching,
  }) {
    final adaptivePlan =
        plan ?? ref.read(adaptiveShiftPlanProvider).valueOrNull;
    final insight = coaching ?? ref.read(shiftCoachInsightProvider);
    final hasActiveShift =
        ref.read(activeShiftSessionProvider).valueOrNull != null;

    final reminder = ShiftAutomationScheduler.plan(
      adaptivePlan: adaptivePlan,
      coaching: insight,
      hasActiveShift: hasActiveShift,
    );

    ShiftAutomationService.instance.syncPreShiftReminder(reminder);
  }
}
