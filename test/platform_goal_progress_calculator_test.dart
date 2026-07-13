import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/goals/domain/entities/goal_entity.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_entity.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_status.dart';
import 'package:driveflow/features/integrations/domain/services/platform_goal_progress_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('goal progress splits daily target by historical share', () {
    final now = DateTime(2026, 7, 10, 12);
    final progress = PlatformGoalProgressCalculator.calculate(
      goals: const GoalEntity(
        id: 'g1',
        userId: 'u1',
        daily: 200,
        weekly: 0,
        monthly: 0,
        yearly: 0,
        updatedAt: null,
      ),
      earnings: const [],
      trips: [
        PlatformTripEntity(
          id: '1',
          userId: 'u',
          platform: RidePlatform.uber,
          externalId: 'a',
          fareAmount: 80,
          tipAmount: 0,
          platformFee: 20,
          driverPayout: 60,
          startedAt: DateTime(2026, 7, 10, 8),
          endedAt: DateTime(2026, 7, 10, 8, 30),
          status: PlatformTripStatus.completed,
        ),
        PlatformTripEntity(
          id: '2',
          userId: 'u',
          platform: RidePlatform.ninetyNine,
          externalId: 'b',
          fareAmount: 40,
          tipAmount: 0,
          platformFee: 10,
          driverPayout: 30,
          startedAt: DateTime(2026, 7, 9, 9),
          endedAt: DateTime(2026, 7, 9, 9, 20),
          status: PlatformTripStatus.completed,
        ),
      ],
      now: now,
    );

    expect(progress, isNotEmpty);
    final uber = progress.firstWhere((p) => p.platform == RidePlatform.uber);
    expect(uber.actualAmount, 60);
    expect(uber.targetAmount, greaterThan(0));
  });
}
