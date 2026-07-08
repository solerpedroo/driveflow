import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/features/goals/domain/entities/goal_entity.dart';
import 'package:driveflow/features/goals/domain/services/goal_progress_calculator.dart';

void main() {
  const goals = GoalEntity(
    id: 'g1',
    userId: 'u1',
    daily: 300,
    weekly: 1500,
    monthly: 6000,
    yearly: 72000,
  );

  group('GoalProgressCalculator', () {
    test('retorna sem meta quando valor alvo é zero', () {
      final progress = GoalProgressCalculator.calculate(
        period: GoalPeriod.daily,
        goals: null,
        earningsTotal: 500,
        expensesTotal: 100,
      );

      expect(progress.hasTarget, isFalse);
      expect(progress.progressPercent, 0);
      expect(progress.actualProfit, 400);
    });

    test('calcula percentual e valor restante', () {
      final progress = GoalProgressCalculator.calculate(
        period: GoalPeriod.daily,
        goals: goals,
        earningsTotal: 350,
        expensesTotal: 50,
      );

      expect(progress.hasTarget, isTrue);
      expect(progress.actualProfit, 300);
      expect(progress.progressPercent, 100);
      expect(progress.remainingAmount, 0);
      expect(progress.isComplete, isTrue);
    });

    test('calcula progresso parcial', () {
      final progress = GoalProgressCalculator.calculate(
        period: GoalPeriod.weekly,
        goals: goals,
        earningsTotal: 800,
        expensesTotal: 200,
      );

      expect(progress.progressPercent, closeTo(40, 0.01));
      expect(progress.remainingAmount, closeTo(900, 0.01));
      expect(progress.isComplete, isFalse);
    });

    test('projeta faltam R\$ X quando abaixo da meta', () {
      final progress = GoalProgressCalculator.calculate(
        period: GoalPeriod.monthly,
        goals: goals,
        earningsTotal: 2000,
        expensesTotal: 500,
      );

      expect(progress.actualProfit, 1500);
      expect(progress.remainingAmount, 4500);
    });
  });
}
