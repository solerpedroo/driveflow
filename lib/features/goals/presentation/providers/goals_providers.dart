import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/transaction_filters.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../expenses/presentation/providers/expenses_providers.dart';
import '../../data/repositories/goals_repository_impl.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goals_repository.dart';
import '../../domain/services/goal_progress_calculator.dart';
import '../../domain/usecases/goals_usecases.dart';

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  return GoalsRepositoryImpl();
});

final goalsStreamProvider = StreamProvider<GoalEntity?>((ref) {
  final watch = WatchGoals(ref.watch(goalsRepositoryProvider));
  return watch();
});

final upsertGoalsProvider = Provider<UpsertGoals>((ref) {
  return UpsertGoals(ref.watch(goalsRepositoryProvider));
});

GoalProgress _computeProgress({
  required GoalPeriod period,
  required GoalEntity? goals,
  required List<EarningEntity> earnings,
  required List<ExpenseEntity> expenses,
}) {
  final range = dateRangeForGoalPeriod(period);
  final earningsTotal = TransactionFilters.sumAmounts(
    TransactionFilters.byDateRange(earnings, range, (e) => e.date),
    (e) => e.amount,
  );
  final expensesTotal = TransactionFilters.sumAmounts(
    TransactionFilters.byDateRange(expenses, range, (e) => e.date),
    (e) => e.amount,
  );

  return GoalProgressCalculator.calculate(
    period: period,
    goals: goals,
    earningsTotal: earningsTotal,
    expensesTotal: expensesTotal,
  );
}

final goalProgressProvider =
    Provider.family<AsyncValue<GoalProgress>, GoalPeriod>((ref, period) {
  final goalsAsync = ref.watch(goalsStreamProvider);
  final earningsAsync = ref.watch(earningsStreamProvider);
  final expensesAsync = ref.watch(expensesStreamProvider);

  if (goalsAsync.isLoading ||
      earningsAsync.isLoading ||
      expensesAsync.isLoading) {
    return const AsyncLoading();
  }

  final error = goalsAsync.error ?? earningsAsync.error ?? expensesAsync.error;
  if (error != null) {
    return AsyncError(
      error,
      goalsAsync.stackTrace ??
          earningsAsync.stackTrace ??
          expensesAsync.stackTrace ??
          StackTrace.current,
    );
  }

  return AsyncData(
    _computeProgress(
      period: period,
      goals: goalsAsync.valueOrNull,
      earnings: earningsAsync.valueOrNull ?? const [],
      expenses: expensesAsync.valueOrNull ?? const [],
    ),
  );
});

final allGoalProgressProvider =
    Provider<AsyncValue<Map<GoalPeriod, GoalProgress>>>((ref) {
  final periods = GoalPeriod.values;
  final loading = periods.any(
    (period) => ref.watch(goalProgressProvider(period)).isLoading,
  );
  if (loading) return const AsyncLoading();

  final errorPeriod = periods.cast<GoalPeriod?>().firstWhere(
        (period) => ref.watch(goalProgressProvider(period!)).hasError,
        orElse: () => null,
      );
  if (errorPeriod != null) {
    final failed = ref.watch(goalProgressProvider(errorPeriod));
    return AsyncError(
      failed.error!,
      failed.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncData({
    for (final period in periods)
      period: ref.watch(goalProgressProvider(period)).requireValue,
  });
});

class GoalsController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<GoalEntity?> save(GoalDraft draft) async {
    state = const AsyncLoading();
    GoalEntity? saved;
    state = await AsyncValue.guard(() async {
      saved = await ref.read(upsertGoalsProvider)(draft);
    });
    if (state.hasError) return null;
    return saved;
  }

  void clearError() => state = const AsyncData(null);
}

final goalsControllerProvider =
    NotifierProvider<GoalsController, AsyncValue<void>>(GoalsController.new);
