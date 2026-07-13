import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/features/expenses/domain/entities/expense_entity.dart';
import 'package:driveflow/features/shift/domain/entities/shift_session_entity.dart';
import 'package:driveflow/features/shift/domain/entities/shift_session_status.dart';
import 'package:driveflow/features/shift/domain/services/shift_net_cash_calculator.dart';

void main() {
  test('computes net cash from session expenses', () {
    final session = ShiftSessionEntity(
      id: 's1',
      startedAt: DateTime(2026, 7, 13, 18),
      endedAt: DateTime(2026, 7, 13, 22),
      status: ShiftSessionStatus.completed,
      planBlocks: const [],
      isTaxiMode: false,
    );

    final expenses = [
      ExpenseEntity(
        id: 'x1',
        userId: 'u1',
        category: ExpenseCategory.fuel,
        amount: 40,
        date: DateTime(2026, 7, 13, 19),
        createdAt: DateTime(2026, 7, 13, 19),
      ),
      ExpenseEntity(
        id: 'x2',
        userId: 'u1',
        category: ExpenseCategory.food,
        amount: 15,
        date: DateTime(2026, 7, 13, 12),
        createdAt: DateTime(2026, 7, 13, 12),
      ),
    ];

    final scoped = ShiftNetCashCalculator.expensesInSession(
      session: session,
      expenses: expenses,
    );

    expect(scoped, hasLength(1));

    final snapshot = ShiftNetCashCalculator.compute(
      revenue: 200,
      elapsed: const Duration(hours: 4),
      scopedExpenses: scoped,
    );

    expect(snapshot.expenses, 40);
    expect(snapshot.netCash, 160);
    expect(snapshot.netPerHour, 40);
    expect(snapshot.expensesByCategory[ExpenseCategory.fuel], 40);
  });
}
