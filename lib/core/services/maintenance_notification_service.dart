import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/maintenance/domain/entities/maintenance_entity.dart';

/// Agenda lembretes locais de manutenção veicular.
class MaintenanceNotificationService {
  MaintenanceNotificationService._();

  static final MaintenanceNotificationService instance =
      MaintenanceNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  int notificationIdFor(String maintenanceId) =>
      maintenanceId.hashCode.abs() % 2147483646 + 1;

  Future<void> syncReminder(MaintenanceEntity record) async {
    final id = notificationIdFor(record.id);
    await cancelReminder(record.id);

    final dueDate = record.nextDueDate;
    if (dueDate == null) return;

    final scheduled = tz.TZDateTime(
      tz.local,
      dueDate.year,
      dueDate.month,
      dueDate.day,
      9,
    );

    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id,
      'Manutenção: ${record.type.label}',
      _bodyFor(record),
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'driveflow_maintenance',
          'Lembretes de manutenção',
          channelDescription: 'Alertas de revisão e manutenção do veículo',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(String maintenanceId) async {
    await _plugin.cancel(notificationIdFor(maintenanceId));
  }

  String _bodyFor(MaintenanceEntity record) {
    final parts = <String>['Hora de cuidar do seu veículo.'];
    if (record.nextDueKm != null) {
      parts.add('Próximo em ${record.nextDueKm!.toStringAsFixed(0)} km.');
    }
    return parts.join(' ');
  }
}
