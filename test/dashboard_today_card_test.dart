import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/features/dashboard/presentation/widgets/dashboard_today_card.dart';
import 'package:driveflow/features/goals/domain/entities/goal_entity.dart';
import 'package:driveflow/features/goals/domain/services/goal_progress_calculator.dart';
import 'package:driveflow/shared/domain/models/period_summary.dart';

void main() {
  testWidgets('DashboardTodayCard exibe lucro e meta do dia', (tester) async {
    const summary = PeriodSummary(
      revenue: 500,
      expenses: 150,
      profit: 350,
      workedHours: 6,
      rides: 10,
      kmDriven: 120,
      fuelExpense: 80,
      profitPerHour: 58.33,
      profitPerKm: 2.91,
      avgCostPerKm: 0.45,
    );

    final goalProgress = GoalProgressCalculator.calculate(
      period: GoalPeriod.daily,
      goals: const GoalEntity(
        id: 'g1',
        userId: 'u1',
        daily: 400,
        weekly: 0,
        monthly: 0,
        yearly: 0,
      ),
      earningsTotal: 500,
      expensesTotal: 150,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardTodayCard(
            summary: summary,
            goalProgress: goalProgress,
          ),
        ),
      ),
    );

    expect(find.text('Hoje'), findsOneWidget);
    expect(find.textContaining('350'), findsWidgets);
    expect(find.textContaining('10'), findsWidgets);
    expect(find.textContaining('88%'), findsOneWidget);
  });
}
