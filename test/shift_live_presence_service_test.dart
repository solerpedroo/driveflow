import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/services/shift_live_presence_service.dart';
import 'package:driveflow/features/shift/domain/entities/shift_session_entity.dart';
import 'package:driveflow/features/shift/domain/entities/shift_session_status.dart';
import 'package:driveflow/features/shift/domain/entities/shift_session_summary.dart';

void main() {
  test('buildPayload formats active shift metrics', () {
    final session = ShiftSessionEntity(
      id: 's1',
      startedAt: DateTime(2026, 7, 13, 18),
      status: ShiftSessionStatus.active,
      isTaxiMode: false,
    );
    final summary = ShiftSessionSummary(
      revenue: 180,
      rides: 4,
      elapsed: const Duration(hours: 2, minutes: 15),
      revenuePerHour: 80,
      goalProgress: 0.5,
    );

    final payload = ShiftLivePresenceService.buildPayload(
      session: session,
      summary: summary,
    );

    expect(payload['title'], 'Turno ativo');
    expect(payload['isPaused'], 'false');
    expect(payload['subtitle'], '4 corridas');
    expect(payload['elapsedLabel'], '02h 15m');
    expect(payload['revenueLabel'], contains('180'));
  });

  test('buildPayload masks values when hidden', () {
    final session = ShiftSessionEntity(
      id: 's1',
      startedAt: DateTime(2026, 7, 13, 18),
      status: ShiftSessionStatus.paused,
      pausedAt: DateTime(2026, 7, 13, 20),
      isTaxiMode: true,
    );
    final summary = ShiftSessionSummary(
      revenue: 90,
      rides: 2,
      elapsed: const Duration(minutes: 45),
      revenuePerHour: null,
      goalProgress: 0,
    );

    final payload = ShiftLivePresenceService.buildPayload(
      session: session,
      summary: summary,
      hideValues: true,
    );

    expect(payload['title'], 'Turno pausado');
    expect(payload['revenueLabel'], '•••');
    expect(payload['subtitle'], '••• corridas');
  });

  test('formatElapsed supports sub-hour durations', () {
    expect(
      ShiftLivePresenceService.formatElapsed(const Duration(minutes: 5, seconds: 7)),
      '05:07',
    );
  });
}
