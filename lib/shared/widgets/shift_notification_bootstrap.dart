import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/services/shift_notification_service.dart';
import '../../features/integrations/presentation/providers/platform_intelligence_providers.dart';
import '../../features/shift/presentation/providers/shift_session_providers.dart';

/// Sincroniza notificações de turno quando o horário de ouro muda.
class ShiftNotificationBootstrap extends ConsumerStatefulWidget {
  const ShiftNotificationBootstrap({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ShiftNotificationBootstrap> createState() =>
      _ShiftNotificationBootstrapState();
}

class _ShiftNotificationBootstrapState
    extends ConsumerState<ShiftNotificationBootstrap> {
  var _lastSwitchSignature = '';

  @override
  Widget build(BuildContext context) {
    ref.listen(platformGoldenHourProvider, (previous, next) {
      next.whenData((slot) {
        ShiftNotificationService.instance.syncFromGoldenHour(slot);
      });
    });

    ref.listen(shiftPlanAdherenceProvider, (previous, next) {
      final session = ref.read(activeShiftSessionProvider).valueOrNull;
      if (session == null || !next.shouldSwitch) return;

      final from = next.currentBlock?.platform.label ?? '';
      final to = next.recommendedPlatform?.label ?? '';
      if (from.isEmpty || to.isEmpty) return;

      final signature = '$from->$to';
      if (signature == _lastSwitchSignature) return;
      _lastSwitchSignature = signature;

      ShiftNotificationService.instance.notifyPlatformSwitch(
        fromLabel: from,
        toLabel: to,
      );
    });

    ref.listen(activeShiftSessionProvider, (previous, next) {
      final wasActive = previous?.valueOrNull != null;
      final isActive = next.valueOrNull != null;
      if (wasActive && !isActive) {
        ShiftNotificationService.instance.cancelMidShiftNotifications();
        _lastSwitchSignature = '';
      }
    });

    return widget.child;
  }
}
