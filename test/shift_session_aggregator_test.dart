import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/earnings/domain/entities/earning_entity.dart';
import 'package:driveflow/features/shift/domain/entities/shift_session_entity.dart';
import 'package:driveflow/features/shift/domain/entities/shift_session_status.dart';
import 'package:driveflow/features/shift/domain/services/shift_session_aggregator.dart';

void main() {
  test('earningsInSession filters by startedAt and vehicle', () {
    final session = ShiftSessionEntity(
      id: 's1',
      startedAt: DateTime(2026, 7, 13, 18),
      status: ShiftSessionStatus.active,
      planBlocks: const [],
      isTaxiMode: false,
      vehicleId: 'v1',
    );

    final earnings = [
      EarningEntity(
        id: 'e1',
        userId: 'u1',
        platform: RidePlatform.uber,
        amount: 80,
        rides: 2,
        workedHours: 1,
        date: DateTime(2026, 7, 13, 19),
        vehicleId: 'v1',
        createdAt: DateTime(2026, 7, 13, 19, 5),
      ),
      EarningEntity(
        id: 'e2',
        userId: 'u1',
        platform: RidePlatform.ninetyNine,
        amount: 40,
        rides: 1,
        workedHours: 0.5,
        date: DateTime(2026, 7, 13, 12),
        vehicleId: 'v1',
        createdAt: DateTime(2026, 7, 13, 12),
      ),
    ];

    final scoped = ShiftSessionAggregator.earningsInSession(
      session: session,
      earnings: earnings,
      vehicleId: 'v1',
    );

    expect(scoped, hasLength(1));
    expect(scoped.first.id, 'e1');
  });

  test('summarize computes revenue per hour', () {
    final session = ShiftSessionEntity(
      id: 's1',
      startedAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: ShiftSessionStatus.active,
      planBlocks: const [],
      isTaxiMode: false,
    );

    final summary = ShiftSessionAggregator.summarize(
      session: session,
      earnings: [
        EarningEntity(
          id: 'e1',
          userId: 'u1',
          platform: RidePlatform.uber,
          amount: 100,
          rides: 3,
          workedHours: 1,
          date: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ],
      now: DateTime.now(),
      dailyGoal: 200,
    );

    expect(summary.revenue, 100);
    expect(summary.rides, 3);
    expect(summary.goalProgress, 0.5);
    expect(summary.revenuePerHour, isNotNull);
  });
}
