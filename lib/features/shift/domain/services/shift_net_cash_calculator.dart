import '../../../expenses/domain/entities/expense_entity.dart';
import '../entities/shift_net_cash_snapshot.dart';
import '../entities/shift_session_entity.dart';

/// Calcula caixa líquido do turno a partir de ganhos e despesas na sessão.
abstract final class ShiftNetCashCalculator {
  static List<ExpenseEntity> expensesInSession({
    required ShiftSessionEntity session,
    required List<ExpenseEntity> expenses,
    String? vehicleId,
  }) {
    return expenses.where((expense) {
      if (vehicleId != null && expense.vehicleId != vehicleId) return false;
      final anchor = expense.createdAt ?? expense.date;
      return !anchor.isBefore(session.startedAt) &&
          (session.endedAt == null || anchor.isBefore(session.endedAt!));
    }).toList(growable: false);
  }

  static ShiftNetCashSnapshot compute({
    required double revenue,
    required Duration elapsed,
    required List<ExpenseEntity> scopedExpenses,
  }) {
    final byCategory = <ExpenseCategory, double>{};
    var expenses = 0.0;

    for (final expense in scopedExpenses) {
      expenses += expense.amount;
      byCategory[expense.category] =
          (byCategory[expense.category] ?? 0) + expense.amount;
    }

    final netCash = revenue - expenses;
    final hours = elapsed.inSeconds / 3600;
    final netPerHour = hours >= 0.05 ? netCash / hours : null;

    return ShiftNetCashSnapshot(
      revenue: revenue,
      expenses: expenses,
      netCash: netCash,
      netPerHour: netPerHour,
      expensesByCategory: byCategory,
    );
  }
}
