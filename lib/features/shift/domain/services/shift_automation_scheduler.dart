import '../../../integrations/domain/entities/platform_shift_plan.dart';
import '../entities/shift_automation_reminder.dart';
import '../entities/shift_coach_insight.dart';
import '../../../../core/deep_links/app_deep_link_routes.dart';

/// Define lembrete de pré-turno com base no plano e coaching.
abstract final class ShiftAutomationScheduler {
  static ShiftAutomationReminder? plan({
    required PlatformShiftPlan? adaptivePlan,
    required ShiftCoachInsight? coaching,
    required bool hasActiveShift,
  }) {
    if (hasActiveShift) return null;

    int? hour;
    String body;

    if (adaptivePlan != null && adaptivePlan.blocks.isNotEmpty) {
      hour = adaptivePlan.blocks.first.startHour;
      body =
          'Seu plano adaptativo começa às ${hour.toString().padLeft(2, '0')}h. '
          'Toque para iniciar com um toque.';
    } else if (coaching?.typicalDeviationHour != null) {
      hour = coaching!.typicalDeviationHour;
      body =
          'Você costuma rodar por volta das ${hour!.toString().padLeft(2, '0')}h. '
          'Prepare o turno agora.';
    } else if (coaching != null && coaching.preferredPlatform != null) {
      hour = DateTime.now().hour;
      body =
          'Hora de sair — ${coaching.preferredPlatform!.label} liderou seus '
          'últimos turnos.';
    } else {
      return null;
    }

    return ShiftAutomationReminder(
      targetHour: hour,
      title: 'Hora de iniciar turno',
      body: body,
      deepLink: AppDeepLinkRoutes.shiftStart().toString(),
    );
  }
}
