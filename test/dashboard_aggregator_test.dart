import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/features/earnings/domain/entities/earning_entity.dart';
import 'package:driveflow/features/expenses/domain/entities/expense_entity.dart';
import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/shared/domain/services/dashboard_aggregator.dart';

void main() {
  group('DashboardAggregator', () {
    test('monta snapshot com hoje, mês e 7 pontos semanais', () {
      final anchor = DateTime(2026, 7, 8); // quarta-feira

      final snapshot = DashboardAggregator.build(
        earnings: [
          EarningEntity(
            id: 'e1',
            userId: 'u1',
            platform: RidePlatform.uber,
            amount: 300,
            rides: 5,
            workedHours: 4,
            date: anchor,
          ),
        ],
        expenses: [
          ExpenseEntity(
            id: 'x1',
            userId: 'u1',
            category: ExpenseCategory.fuel,
            amount: 80,
            date: anchor,
          ),
        ],
        fuelLogs: const [],
        anchor: anchor,
      );

      expect(snapshot.today.profit, 220);
      expect(snapshot.month.profit, 220);
      expect(snapshot.weekProfits, hasLength(7));
      final wednesday = snapshot.weekProfits[2];
      expect(wednesday.profit, 220);
      expect(snapshot.weekProfits.first.weekdayLabel, isNotEmpty);
    });
  });
}
