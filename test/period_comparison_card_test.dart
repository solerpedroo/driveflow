import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/features/analytics/domain/entities/analytics_enums.dart';
import 'package:driveflow/features/analytics/domain/entities/period_comparison_result.dart';
import 'package:driveflow/features/analytics/presentation/widgets/period_comparison_card.dart';
import 'package:driveflow/features/goals/domain/entities/goal_entity.dart';

void main() {
  testWidgets('PeriodComparisonCard exibe métricas e variação', (tester) async {
    const comparison = PeriodComparisonResult(
      period: GoalPeriod.monthly,
      reference: ComparisonReference.previousPeriod,
      metrics: [
        PeriodMetricDelta(
          label: 'Lucro',
          current: 500,
          previous: 400,
          delta: 100,
          deltaPercent: 25,
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PeriodComparisonCard(comparison: comparison),
        ),
      ),
    );

    expect(find.text('Comparativo — Mensal'), findsOneWidget);
    expect(find.text('Lucro'), findsOneWidget);
    expect(find.textContaining('+25.0%'), findsOneWidget);
  });
}
