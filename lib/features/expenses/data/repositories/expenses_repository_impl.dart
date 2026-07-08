import 'dart:io';

import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../datasources/expenses_remote_datasource.dart';
import '../mappers/expenses_mapper.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  ExpensesRepositoryImpl({ExpensesRemoteDataSource? remote})
      : _remote = remote ?? ExpensesRemoteDataSource();

  final ExpensesRemoteDataSource _remote;

  @override
  Stream<List<ExpenseEntity>> watchExpenses() {
    return _remote.watchExpenses().map(
          (rows) => rows.map(ExpensesMapper.fromRow).toList(growable: false),
        );
  }

  @override
  Future<List<ExpenseEntity>> fetchExpenses() async {
    final rows = await _remote.fetchExpenses();
    return rows.map(ExpensesMapper.fromRow).toList(growable: false);
  }

  Future<String?> uploadReceipt(File file) => _remote.uploadReceipt(file);

  @override
  Future<ExpenseEntity> createExpense(ExpenseDraft draft) async {
    final row = await _remote.createExpense(draft: draft);
    return ExpensesMapper.fromRow(row);
  }

  @override
  Future<ExpenseEntity> updateExpense({
    required String id,
    required ExpenseDraft draft,
  }) async {
    final row = await _remote.updateExpense(id: id, draft: draft);
    return ExpensesMapper.fromRow(row);
  }

  @override
  Future<void> deleteExpense(String id) => _remote.deleteExpense(id);
}
