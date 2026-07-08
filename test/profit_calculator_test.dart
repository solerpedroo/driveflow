import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/core/constants/date_range_period.dart';
import 'package:driveflow/features/earnings/domain/entities/earning_entity.dart';
import 'package:driveflow/features/expenses/domain/entities/expense_entity.dart';
import 'package:driveflow/features/fuel/domain/entities/fuel_log_entity.dart';
import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/shared/domain/services/profit_calculator.dart';

void main() {
  EarningEntity earning({
    required DateTime date,
    double amount = 100,
    double hours = 2,
    int rides = 3,
  }) {
    return EarningEntity(
      id: 'e1',
      userId: 'u1',
      platform: RidePlatform.uber,
      amount: amount,
      rides: rides,
      workedHours: hours,
      date: date,
    );
  }

  ExpenseEntity expense({
    required DateTime date,
    double amount = 40,
    ExpenseCategory category = ExpenseCategory.fuel,
  }) {
    return ExpenseEntity(
      id: 'x1',
      userId: 'u1',
      category: category,
      amount: amount,
      date: date,
    );
  }

  FuelLogEntity fuelLog({
    required double odometer,
    double liters = 40,
    double? kmPerLiter,
  }) {
    return FuelLogEntity(
      id: 'f1',
      vehicleId: 'v1',
      userId: 'u1',
      fuelType: FuelType.gasoline,
      pricePerLiter: 5,
      liters: liters,
      totalAmount: liters * 5,
      odometerKm: odometer,
      kmPerLiter: kmPerLiter,
      costPerKm: kmPerLiter != null ? 5 / kmPerLiter : null,
      createdAt: DateTime(2026, 7, 8),
    );
  }

  group('ProfitCalculator', () {
    test('calcula lucro como receita menos despesas', () {
      expect(ProfitCalculator.profit(500, 200), 300);
    });

    test('calcula lucro por hora e por km', () {
      expect(ProfitCalculator.profitPerHour(300, 6), 50);
      expect(ProfitCalculator.profitPerKm(200, 100), 2);
    });

    test('resume período com ganhos, despesas e combustível', () {
      final range = DateRange(
        start: DateTime(2026, 7, 8),
        end: DateTime(2026, 7, 8, 23, 59, 59, 999),
      );

      final summary = ProfitCalculator.summarize(
        earnings: [
          earning(date: DateTime(2026, 7, 8), amount: 400, hours: 5, rides: 8),
        ],
        expenses: [
          expense(date: DateTime(2026, 7, 8), amount: 120),
          expense(
            date: DateTime(2026, 7, 8),
            amount: 30,
            category: ExpenseCategory.food,
          ),
        ],
        fuelLogs: [
          fuelLog(odometer: 10000, kmPerLiter: 10, liters: 20),
        ],
        range: range,
      );

      expect(summary.revenue, 400);
      expect(summary.expenses, 150);
      expect(summary.profit, 250);
      expect(summary.workedHours, 5);
      expect(summary.rides, 8);
      expect(summary.fuelExpense, 120);
      expect(summary.profitPerHour, 50);
      expect(summary.kmDriven, 200);
      expect(summary.profitPerKm, closeTo(1.25, 0.01));
    });
  });
}
