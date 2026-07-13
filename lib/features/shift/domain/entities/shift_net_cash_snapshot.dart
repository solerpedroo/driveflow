import '../../../expenses/domain/entities/expense_entity.dart';
import '../entities/shift_session_entity.dart';

/// Caixa líquido do turno — ganhos menos despesas na janela da sessão.
class ShiftNetCashSnapshot {
  const ShiftNetCashSnapshot({
    required this.revenue,
    required this.expenses,
    required this.netCash,
    required this.expensesByCategory,
    this.netPerHour,
  });

  final double revenue;
  final double expenses;
  final double netCash;
  final double? netPerHour;
  final Map<ExpenseCategory, double> expensesByCategory;

  bool get hasExpenses => expenses > 0;
}
