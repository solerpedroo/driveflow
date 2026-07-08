import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/analytics/domain/services/profit_forecast_calculator.dart';
import 'package:driveflow/features/earnings/domain/entities/earning_entity.dart';
import 'package:driveflow/features/expenses/domain/entities/expense_entity.dart';

void main() {
  group('ProfitForecastCalculator', () {
    test('projeta 7 e 30 dias a partir da média diária', () {
      final anchor = DateTime(2026, 7, 8);
      final earnings = List.generate(
        10,
        (index) => EarningEntity(
          id: 'e$index',
          userId: 'u1',
          platform: RidePlatform.uber,
          amount: 300,
          rides: 5,
          workedHours: 4,
          date: anchor.subtract(Duration(days: index)),
        ),
      );
      final expenses = List.generate(
        10,
        (index) => ExpenseEntity(
          id: 'x$index',
          userId: 'u1',
          category: ExpenseCategory.fuel,
          amount: 100,
          date: anchor.subtract(Duration(days: index)),
        ),
      );

      final forecast = ProfitForecastCalculator.compute(
        earnings: earnings,
        expenses: expenses,
        anchor: anchor,
      );

      expect(forecast.averageDailyProfit, closeTo(200, 0.01));
      expect(forecast.forecast7Days, closeTo(1400, 0.01));
      expect(forecast.forecast30Days, closeTo(6000, 0.01));
      expect(forecast.optimistic30Days, greaterThan(forecast.forecast30Days));
      expect(forecast.pessimistic30Days, lessThan(forecast.forecast30Days));
    });
  });
}
