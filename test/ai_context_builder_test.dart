import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/ai/domain/services/ai_context_builder.dart';
import 'package:driveflow/features/earnings/domain/entities/earning_entity.dart';
import 'package:driveflow/features/expenses/domain/entities/expense_entity.dart';
import 'package:driveflow/features/fuel/domain/entities/fuel_log_entity.dart';
import 'package:driveflow/features/goals/domain/entities/goal_entity.dart';
import 'package:driveflow/shared/domain/models/period_summary.dart';

void main() {
  group('AiContextBuilder', () {
    test('monta snapshot JSON com lucro do mês', () {
      final anchor = DateTime(2026, 7, 8);

      final snapshot = AiContextBuilder.build(
        earnings: [
          EarningEntity(
            id: 'e1',
            userId: 'u1',
            platform: RidePlatform.uber,
            amount: 1200,
            rides: 20,
            workedHours: 30,
            date: anchor,
          ),
        ],
        expenses: [
          ExpenseEntity(
            id: 'x1',
            userId: 'u1',
            category: ExpenseCategory.fuel,
            amount: 400,
            date: anchor,
          ),
        ],
        fuelLogs: [
          FuelLogEntity(
            id: 'f1',
            vehicleId: 'v1',
            userId: 'u1',
            fuelType: FuelType.gasoline,
            pricePerLiter: 5,
            liters: 40,
            totalAmount: 200,
            odometerKm: 50000,
            costPerKm: 0.42,
            createdAt: anchor,
          ),
        ],
        maintenanceRecords: const [],
        goals: const GoalEntity(
          id: 'g1',
          userId: 'u1',
          daily: 300,
          weekly: 1500,
          monthly: 6000,
          yearly: 72000,
        ),
        currentOdometerKm: 50000,
      );

      expect(snapshot.month.profit, 800);
      expect(snapshot.earningsCount, 1);
      expect(snapshot.lastFuelCostPerKm, 0.42);

      final json = snapshot.toJson();
      expect(json['month']['profit'], 800);
      expect(json['goals']['monthly'], 6000);
    });

    test('formatForPrompt inclui metas e lucro', () {
      const snapshot = AiContextSnapshot(
        periodDays: 90,
        today: PeriodSummary.empty,
        month: PeriodSummary(
          revenue: 5000,
          expenses: 2000,
          profit: 3000,
          workedHours: 40,
          rides: 80,
          kmDriven: 1200,
          fuelExpense: 900,
          profitPerHour: 75,
          profitPerKm: 2.5,
          avgCostPerKm: 0.4,
        ),
        year: PeriodSummary.empty,
        goals: GoalEntity(
          id: 'g1',
          userId: 'u1',
          daily: 250,
          weekly: 1200,
          monthly: 5000,
          yearly: 60000,
        ),
        earningsCount: 10,
        expensesCount: 8,
        fuelLogsCount: 3,
        maintenanceAlerts: 1,
        lastFuelCostPerKm: 0.38,
      );

      final prompt = AiContextBuilder.formatForPrompt(snapshot);

      expect(prompt, contains('Mês — lucro: 3000'));
      expect(prompt, contains('mensal: 5000'));
      expect(prompt, contains('Alertas de manutenção: 1'));
    });
  });
}
