import '../entities/expense_entity.dart';
import '../repositories/expenses_repository.dart';

class WatchExpenses {
  const WatchExpenses(this._repository);

  final ExpensesRepository _repository;

  Stream<List<ExpenseEntity>> call() => _repository.watchExpenses();
}

class CreateExpense {
  const CreateExpense(this._repository);

  final ExpensesRepository _repository;

  Future<ExpenseEntity> call(ExpenseDraft draft) =>
      _repository.createExpense(draft);
}

class UpdateExpense {
  const UpdateExpense(this._repository);

  final ExpensesRepository _repository;

  Future<ExpenseEntity> call({
    required String id,
    required ExpenseDraft draft,
  }) =>
      _repository.updateExpense(id: id, draft: draft);
}

class DeleteExpense {
  const DeleteExpense(this._repository);

  final ExpensesRepository _repository;

  Future<void> call(String id) => _repository.deleteExpense(id);
}
