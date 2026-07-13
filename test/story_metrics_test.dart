import 'package:driveflow/core/utils/story_metrics.dart';
import 'package:driveflow/features/goals/domain/entities/goal_entity.dart';
import 'package:driveflow/features/goals/domain/services/goal_progress_calculator.dart';
import 'package:driveflow/shared/domain/models/daily_profit_point.dart';
import 'package:driveflow/shared/domain/models/period_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('heroSubtitle suggests first ride when empty', () {
    final subtitle = StoryMetrics.heroSubtitle(
      today: PeriodSummary.empty,
      goalProgress: GoalProgressCalculator.calculate(
        period: GoalPeriod.daily,
        goals: null,
        earningsTotal: 0,
        expensesTotal: 0,
      ),
      weekProfits: const [],
    );

    expect(subtitle, contains('primeira corrida'));
  });

  test('valueCards includes month profit when positive', () {
    final cards = StoryMetrics.valueCards(
      today: const PeriodSummary(
        revenue: 120,
        expenses: 20,
        profit: 100,
        rides: 4,
        workedHours: 3,
        fuelExpense: 10,
        kmDriven: 40,
        profitPerHour: 33.33,
        profitPerKm: 2.5,
        avgCostPerKm: 0.25,
      ),
      month: const PeriodSummary(
        revenue: 3000,
        expenses: 900,
        profit: 2100,
        rides: 80,
        workedHours: 60,
        fuelExpense: 400,
        kmDriven: 900,
        profitPerHour: 35,
        profitPerKm: 2.3,
        avgCostPerKm: 0.44,
      ),
      goalProgress: GoalProgressCalculator.calculate(
        period: GoalPeriod.daily,
        goals: const GoalEntity(
          id: 'g1',
          userId: 'u1',
          daily: 200,
          weekly: 0,
          monthly: 0,
          yearly: 0,
          updatedAt: null,
        ),
        earningsTotal: 120,
        expensesTotal: 20,
      ),
    );

    expect(cards.any((c) => c.label == 'Lucro no mês'), isTrue);
    expect(cards.any((c) => c.label == 'Lucro/hora hoje'), isTrue);
  });
}
