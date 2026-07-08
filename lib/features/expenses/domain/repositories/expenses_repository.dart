import '../entities/expense_entity.dart';

abstract interface class ExpensesRepository {
  Stream<List<ExpenseEntity>> watchExpenses();

  Future<List<ExpenseEntity>> fetchExpenses();

  Future<ExpenseEntity> createExpense(ExpenseDraft draft);

  Future<ExpenseEntity> updateExpense({
    required String id,
    required ExpenseDraft draft,
  });

  Future<void> deleteExpense(String id);
}
