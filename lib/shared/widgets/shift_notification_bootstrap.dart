import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/services/shift_notification_service.dart';
import '../../features/integrations/presentation/providers/platform_intelligence_providers.dart';

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
  @override
  Widget build(BuildContext context) {
    ref.listen(platformGoldenHourProvider, (previous, next) {
      next.whenData((slot) {
        ShiftNotificationService.instance.syncFromGoldenHour(slot);
      });
    });

    return widget.child;
  }
}
