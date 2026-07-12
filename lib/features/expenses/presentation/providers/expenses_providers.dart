import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/presentation/providers/sync_providers.dart';
import '../../../../core/constants/date_range_period.dart';
import '../../../../core/utils/transaction_filters.dart';
import '../../data/repositories/expenses_repository_impl.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/usecases/expenses_usecases.dart';

final expensesRepositoryProvider = Provider<ExpensesRepositoryImpl>((ref) {
  return ExpensesRepositoryImpl(
    cache: ref.watch(localEntityCacheProvider),
    syncQueue: ref.watch(pendingSyncQueueProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    syncWorker: ref.watch(syncWorkerProvider),
  );
});

final expensesStreamProvider =
    StreamProvider.autoDispose<List<ExpenseEntity>>((ref) {
  final watch = WatchExpenses(ref.watch(expensesRepositoryProvider));
  return watch();
});

final expensesPeriodProvider =
    StateProvider<DateRangePeriod>((ref) => DateRangePeriod.month);

final expensesListProvider = Provider<AsyncValue<List<ExpenseEntity>>>((ref) {
  final stream = ref.watch(expensesStreamProvider);
  final period = ref.watch(expensesPeriodProvider);
  final range = dateRangeForPeriod(period);

  return stream.whenData(
    (items) => TransactionFilters.byDateRange(items, range, (e) => e.date),
  );
});

final expensesTotalProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(expensesListProvider).whenData(
        (items) => TransactionFilters.sumAmounts(items, (e) => e.amount),
      );
});

/// Despesas agrupadas por categoria para a listagem.
final expensesGroupedProvider =
    Provider<AsyncValue<Map<ExpenseCategory, List<ExpenseEntity>>>>((ref) {
  return ref.watch(expensesListProvider).whenData((items) {
    final grouped = <ExpenseCategory, List<ExpenseEntity>>{};
    for (final expense in items) {
      grouped.putIfAbsent(expense.category, () => []).add(expense);
    }
    return grouped;
  });
});

final createExpenseProvider = Provider<CreateExpense>((ref) {
  return CreateExpense(ref.watch(expensesRepositoryProvider));
});

final updateExpenseProvider = Provider<UpdateExpense>((ref) {
  return UpdateExpense(ref.watch(expensesRepositoryProvider));
});

final deleteExpenseProvider = Provider<DeleteExpense>((ref) {
  return DeleteExpense(ref.watch(expensesRepositoryProvider));
});

class ExpensesController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<ExpenseEntity?> save({
    String? expenseId,
    required ExpenseDraft draft,
    File? receiptFile,
  }) async {
    state = const AsyncLoading();
    ExpenseEntity? saved;
    state = await AsyncValue.guard(() async {
      var receiptUrl = draft.receiptUrl;
      if (receiptFile != null) {
        receiptUrl =
            await ref.read(expensesRepositoryProvider).uploadReceipt(receiptFile);
      }
      final resolvedDraft = ExpenseDraft(
        category: draft.category,
        amount: draft.amount,
        date: draft.date,
        description: draft.description,
        receiptUrl: receiptUrl,
        vehicleId: draft.vehicleId,
      );
      if (expenseId == null) {
        saved = await ref.read(createExpenseProvider)(resolvedDraft);
      } else {
        saved = await ref.read(updateExpenseProvider)(
          id: expenseId,
          draft: resolvedDraft,
        );
      }
    });
    if (state.hasError) return null;
    return saved;
  }

  Future<bool> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteExpenseProvider)(id);
    });
    return !state.hasError;
  }

  void clearError() => state = const AsyncData(null);
}

final expensesControllerProvider =
    NotifierProvider<ExpensesController, AsyncValue<void>>(ExpensesController.new);
