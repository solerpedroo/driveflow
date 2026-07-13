import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../features/integrations/domain/entities/platform_golden_hour_slot.dart';
import '../deep_links/app_deep_link_routes.dart';
import 'maintenance_notification_service.dart';

/// Notificações locais de sugestão de turno — estilo "Abra 99 entre 18h–22h".
class ShiftNotificationService {
  ShiftNotificationService._();

  static final ShiftNotificationService instance = ShiftNotificationService._();

  static const _notificationId = 900_001;
  static const _switchNotificationId = 900_002;
  static const _endSummaryNotificationId = 900_003;
  static const _channelId = 'driveflow_shift';
  static const _channelName = 'Sugestões de turno';

  final FlutterLocalNotificationsPlugin _plugin =
      MaintenanceNotificationService.instance.notificationsPlugin;

  Future<void> cancelShiftSuggestion() async {
    await _plugin.cancel(_notificationId);
  }

  /// Agenda notificação para o próximo slot de horário de ouro.
  Future<void> syncFromGoldenHour(PlatformGoldenHourSlot? slot) async {
    await cancelShiftSuggestion();
    if (slot == null) return;

    final scheduled = _nextOccurrence(slot);
    if (scheduled == null) return;
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      _notificationId,
      'Melhor horário para rodar',
      'Abra ${slot.platform.label} entre ${slot.hourLabel} — '
      'média ${slot.avgPayoutPerHour.toStringAsFixed(0)}/h '
      '(${slot.weekdayLabel})',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription:
              'Sugestões de turno com base no seu histórico de corridas',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: AppDeepLinkRoutes.shiftMode().toString(),
    );
  }

  tz.TZDateTime? _nextOccurrence(PlatformGoldenHourSlot slot) {
    final hour = int.tryParse(slot.hourLabel.replaceAll('h', ''));
    if (hour == null) return null;

    final weekdays = {
      'Dom': DateTime.sunday,
      'Seg': DateTime.monday,
      'Ter': DateTime.tuesday,
      'Qua': DateTime.wednesday,
      'Qui': DateTime.thursday,
      'Sex': DateTime.friday,
      'Sáb': DateTime.saturday,
    };
    final targetWeekday = weekdays[slot.weekdayLabel];
    if (targetWeekday == null) return null;

    var candidate = tz.TZDateTime(
      tz.local,
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      hour,
    );

    while (candidate.weekday != targetWeekday) {
      candidate = candidate.add(const Duration(days: 1));
    }

    if (candidate.isBefore(tz.TZDateTime.now(tz.local))) {
      candidate = candidate.add(const Duration(days: 7));
    }

    return candidate.subtract(const Duration(minutes: 15));
  }

  Future<void> cancelMidShiftNotifications() async {
    await _plugin.cancel(_switchNotificationId);
    await _plugin.cancel(_endSummaryNotificationId);
  }

  /// Notificação imediata quando o plano sugere trocar de app.
  Future<void> notifyPlatformSwitch({
    required String fromLabel,
    required String toLabel,
  }) async {
    await _plugin.show(
      _switchNotificationId,
      'Hora de trocar de app',
      'Seu plano sugere $toLabel agora (bloco atual: $fromLabel).',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription:
              'Sugestões de turno com base no seu histórico de corridas',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: AppDeepLinkRoutes.shiftMode().toString(),
    );
  }

  /// Resumo ao encerrar o turno.
  Future<void> notifyShiftEnded({
    required String revenueLabel,
    required String elapsedLabel,
  }) async {
    await _plugin.show(
      _endSummaryNotificationId,
      'Turno encerrado',
      'Você faturou $revenueLabel em $elapsedLabel. Bom descanso!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription:
              'Sugestões de turno com base no seu histórico de corridas',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: AppDeepLinkRoutes.shiftHistory().toString(),
    );
  }
}
