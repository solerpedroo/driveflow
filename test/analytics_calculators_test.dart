import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/core/constants/date_range_period.dart';
import 'package:driveflow/features/analytics/domain/entities/analytics_enums.dart';
import 'package:driveflow/features/analytics/domain/services/category_breakdown_calculator.dart';
import 'package:driveflow/features/analytics/domain/services/comparison_range_resolver.dart';
import 'package:driveflow/features/analytics/domain/services/period_comparison_calculator.dart';
import 'package:driveflow/features/analytics/domain/services/profit_trend_calculator.dart';
import 'package:driveflow/features/earnings/domain/entities/earning_entity.dart';
import 'package:driveflow/features/expenses/domain/entities/expense_entity.dart';
import 'package:driveflow/features/goals/domain/entities/goal_entity.dart';
import 'package:driveflow/core/constants/ride_platforms.dart';

void main() {
  final anchor = DateTime(2026, 7, 15, 12);

  final earnings = [
    EarningEntity(
      id: 'e1',
      userId: 'u1',
      platform: RidePlatform.uber,
      amount: 300,
      rides: 5,
      workedHours: 4,
      date: DateTime(2026, 7, 15),
    ),
    EarningEntity(
      id: 'e2',
      userId: 'u1',
      platform: RidePlatform.ninetyNine,
      amount: 200,
      rides: 3,
      workedHours: 3,
      date: DateTime(2026, 6, 20),
    ),
  ];

  final expenses = [
    ExpenseEntity(
      id: 'x1',
      userId: 'u1',
      category: ExpenseCategory.fuel,
      amount: 100,
      date: DateTime(2026, 7, 10),
    ),
    ExpenseEntity(
      id: 'x2',
      userId: 'u1',
      category: ExpenseCategory.food,
      amount: 50,
      date: DateTime(2026, 7, 12),
    ),
    ExpenseEntity(
      id: 'x3',
      userId: 'u1',
      category: ExpenseCategory.toll,
      amount: 30,
      date: DateTime(2026, 6, 5),
    ),
  ];

  group('ComparisonRangeResolver', () {
    test('resolve período mensal anterior', () {
      final periods = ComparisonRangeResolver.resolve(
        period: GoalPeriod.monthly,
        reference: ComparisonReference.previousPeriod,
        anchor: anchor,
      );

      expect(periods.currentRange.start.month, 7);
      expect(periods.referenceRange.start.month, 6);
    });
  });

  group('PeriodComparisonCalculator', () {
    test('compara lucro do mês atual vs anterior', () {
      final result = PeriodComparisonCalculator.compare(
        period: GoalPeriod.monthly,
        reference: ComparisonReference.previousPeriod,
        earnings: earnings,
        expenses: expenses,
        fuelLogs: const [],
        anchor: anchor,
      );

      final profitMetric =
          result.metrics.firstWhere((metric) => metric.label == 'Lucro');
      expect(profitMetric.current, 150);
      expect(profitMetric.previous, 170);
      expect(profitMetric.delta, -20);
    });
  });

  group('CategoryBreakdownCalculator', () {
    test('agrupa despesas do mês com percentuais', () {
      final range = DateRange(
        start: DateTime(2026, 7, 1),
        end: DateTime(2026, 7, 31, 23, 59, 59, 999),
      );

      final slices = CategoryBreakdownCalculator.build(
        expenses: expenses,
        range: range,
      );

      expect(slices, hasLength(2));
      expect(slices.first.category, ExpenseCategory.fuel);
      expect(slices.first.share, closeTo(100 / 150, 0.01));
    });

    test('retorna vazio sem despesas no período', () {
      final slices = CategoryBreakdownCalculator.build(
        expenses: expenses,
        range: DateRange(
          start: DateTime(2025, 1, 1),
          end: DateTime(2025, 1, 31),
        ),
      );
      expect(slices, isEmpty);
    });
  });

  group('ProfitTrendCalculator', () {
    test('gera série com N pontos', () {
      final points = ProfitTrendCalculator.build(
        earnings: earnings,
        expenses: expenses,
        window: TrendWindow.days30,
        anchor: anchor,
      );

      expect(points, hasLength(30));
      expect(points.last.profit, 300);
    });
  });
}
