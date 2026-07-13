import 'dart:io';

import 'package:live_activities/live_activities.dart';

import '../../features/shift/domain/entities/shift_session_entity.dart';
import '../../features/shift/domain/entities/shift_session_status.dart';
import '../../features/shift/domain/entities/shift_session_summary.dart';
import '../utils/currency_formatter.dart';
import 'home_widget_service.dart';

/// Presença em tempo real do turno — Live Activity (iOS) e notificação ongoing (Android).
abstract final class ShiftLivePresenceService {
  static const activityId = 'shift_active';
  static const appGroupId = HomeWidgetService.appGroupId;

  static LiveActivities? _plugin;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    if (_initialized) return;

    _plugin = LiveActivities();
    await _plugin!.init(
      appGroupId: appGroupId,
      urlScheme: 'driveflow',
    );
    _initialized = true;
  }

  static Map<String, dynamic> buildPayload({
    required ShiftSessionEntity session,
    required ShiftSessionSummary summary,
    bool hideValues = false,
  }) {
    final isPaused = session.status == ShiftSessionStatus.paused;
    return {
      'title': isPaused ? 'Turno pausado' : 'Turno ativo',
      'revenueLabel':
          hideValues ? '•••' : CurrencyFormatter.format(summary.revenue),
      'elapsedLabel': formatElapsed(summary.elapsed),
      'subtitle': hideValues ? '••• corridas' : '${summary.rides} corridas',
      'isPaused': isPaused ? 'true' : 'false',
      'startedAtMs': '${session.startedAt.millisecondsSinceEpoch}',
    };
  }

  static String formatElapsed(Duration elapsed) {
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '$minutes:$seconds';
  }

  static Future<void> sync({
    required ShiftSessionEntity session,
    required ShiftSessionSummary summary,
    bool hideValues = false,
  }) async {
    if (!_initialized || _plugin == null) return;

    final enabled = await _plugin!.areActivitiesEnabled();
    if (!enabled) return;

    final payload = buildPayload(
      session: session,
      summary: summary,
      hideValues: hideValues,
    );

    await _plugin!.createOrUpdateActivity(activityId, payload);
  }

  static Future<void> clear() async {
    if (!_initialized || _plugin == null) return;
    await _plugin!.endActivity(activityId);
  }
}
