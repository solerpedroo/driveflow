import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../features/shift/domain/entities/shift_automation_reminder.dart';
import 'maintenance_notification_service.dart';

/// Agenda lembretes automáticos de turno com deep link acionável.
class ShiftAutomationService {
  ShiftAutomationService._();

  static final ShiftAutomationService instance = ShiftAutomationService._();

  static const _preShiftNotificationId = 900_004;
  static const _channelId = 'driveflow_shift_automation';
  static const _channelName = 'Automação de turno';

  final FlutterLocalNotificationsPlugin _plugin =
      MaintenanceNotificationService.instance.notificationsPlugin;

  Future<void> cancelPreShiftReminder() async {
    await _plugin.cancel(_preShiftNotificationId);
  }

  Future<void> syncPreShiftReminder(ShiftAutomationReminder? reminder) async {
    await cancelPreShiftReminder();
    if (reminder == null) return;

    final scheduled = _nextOccurrence(reminder.targetHour);
    if (scheduled == null) return;
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      _preShiftNotificationId,
      reminder.title,
      reminder.body,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription:
              'Lembretes para iniciar turno com plano sugerido',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: reminder.deepLink,
    );
  }

  tz.TZDateTime? _nextOccurrence(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
    );

    if (candidate.isBefore(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }

    return candidate.subtract(const Duration(minutes: 15));
  }
}
