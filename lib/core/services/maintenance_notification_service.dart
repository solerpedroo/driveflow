import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/maintenance/domain/entities/maintenance_entity.dart';
import '../../features/insights/domain/entities/maintenance_prediction.dart';

/// Agenda lembretes locais de manutenção veicular.
class MaintenanceNotificationService {
  MaintenanceNotificationService._();

  static final MaintenanceNotificationService instance =
      MaintenanceNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Plugin compartilhado para outros serviços de notificação local.
  FlutterLocalNotificationsPlugin get notificationsPlugin => _plugin;

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

    await _scheduleAt(
      id: id,
      record: record,
      scheduled: _atNineAm(dueDate),
      bodySuffix: null,
    );
  }

  /// Reagenda lembrete com data prevista pelo modelo preditivo.
  Future<void> syncPredictiveReminder({
    required MaintenanceEntity record,
    required DateTime predictedDueDate,
    required PredictionConfidence confidence,
  }) async {
    final id = notificationIdFor(record.id);
    await cancelReminder(record.id);

    final scheduled = _atNineAm(predictedDueDate);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _scheduleAt(
      id: id,
      record: record,
      scheduled: scheduled,
      bodySuffix: 'Previsão (${confidence.label}).',
    );
  }

  Future<void> _scheduleAt({
    required int id,
    required MaintenanceEntity record,
    required tz.TZDateTime scheduled,
    String? bodySuffix,
  }) async {
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    var body = _bodyFor(record);
    if (bodySuffix != null) body = '$body $bodySuffix';

    await _plugin.zonedSchedule(
      id,
      'Manutenção: ${record.type.label}',
      body,
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

  tz.TZDateTime _atNineAm(DateTime dueDate) {
    return tz.TZDateTime(
      tz.local,
      dueDate.year,
      dueDate.month,
      dueDate.day,
      9,
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
