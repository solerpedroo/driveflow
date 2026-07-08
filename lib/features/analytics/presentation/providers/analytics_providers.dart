import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../expenses/presentation/providers/expenses_providers.dart';
import '../../../fuel/presentation/providers/fuel_providers.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../../../reports/presentation/providers/reports_providers.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../../../core/utils/vehicle_scope_filter.dart';
import '../domain/entities/analytics_enums.dart';
import '../domain/entities/category_breakdown_slice.dart';
import '../domain/entities/period_comparison_result.dart';
import '../domain/services/category_breakdown_calculator.dart';
import '../domain/services/period_comparison_calculator.dart';
import '../domain/services/profit_trend_calculator.dart';
import '../../../../shared/domain/models/daily_profit_point.dart';

final analyticsTrendWindowProvider =
    StateProvider<TrendWindow>((ref) => TrendWindow.days30);

final analyticsComparisonReferenceProvider =
    StateProvider<ComparisonReference>((ref) => ComparisonReference.previousPeriod);

final analyticsPeriodProvider =
    StateProvider<GoalPeriod>((ref) => GoalPeriod.monthly);

List<T> _scoped<T>({
  required List<T> items,
  required String? vehicleId,
  required String? Function(T item) vehicleIdOf,
}) {
  return VehicleScopeFilter.byVehicle(
    items: items,
    vehicleId: vehicleId,
    vehicleIdOf: vehicleIdOf,
  );
}

final analyticsProfitTrendProvider =
    Provider<AsyncValue<List<DailyProfitPoint>>>((ref) {
  final window = ref.watch(analyticsTrendWindowProvider);
  final earningsAsync = ref.watch(earningsStreamProvider);
  final expensesAsync = ref.watch(expensesStreamProvider);
  final scopedVehicleId = ref.watch(scopedVehicleIdProvider);

  return earningsAsync.when(
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
    data: (earnings) => expensesAsync.when(
      loading: () => const AsyncLoading(),
      error: (e, st) => AsyncError(e, st),
      data: (expenses) {
        final scopedEarnings = _scoped(
          items: earnings,
          vehicleId: scopedVehicleId,
          vehicleIdOf: (e) => e.vehicleId,
        );
        final scopedExpenses = _scoped(
          items: expenses,
          vehicleId: scopedVehicleId,
          vehicleIdOf: (e) => e.vehicleId,
        );
        return AsyncData(
          ProfitTrendCalculator.build(
            earnings: scopedEarnings,
            expenses: scopedExpenses,
            window: window,
          ),
        );
      },
    ),
  );
});

final analyticsCategoryBreakdownProvider =
    Provider<AsyncValue<List<CategoryBreakdownSlice>>>((ref) {
  final period = ref.watch(analyticsPeriodProvider);
  final expensesAsync = ref.watch(expensesStreamProvider);
  final scopedVehicleId = ref.watch(scopedVehicleIdProvider);
  final range = dateRangeForGoalPeriod(period);

  return expensesAsync.whenData((expenses) {
    final scoped = _scoped(
      items: expenses,
      vehicleId: scopedVehicleId,
      vehicleIdOf: (e) => e.vehicleId,
    );
    return CategoryBreakdownCalculator.build(
      expenses: scoped,
      range: range,
    );
  });
});

final analyticsComparisonProvider =
    Provider<AsyncValue<PeriodComparisonResult>>((ref) {
  final period = ref.watch(analyticsPeriodProvider);
  final reference = ref.watch(analyticsComparisonReferenceProvider);
  final earningsAsync = ref.watch(earningsStreamProvider);
  final expensesAsync = ref.watch(expensesStreamProvider);
  final fuelAsync = ref.watch(activeVehicleFuelLogsProvider);
  final scopedVehicleId = ref.watch(scopedVehicleIdProvider);

  if (earningsAsync.isLoading ||
      expensesAsync.isLoading ||
      fuelAsync.isLoading) {
    return const AsyncLoading();
  }

  final error =
      earningsAsync.error ?? expensesAsync.error ?? fuelAsync.error;
  if (error != null) {
    return AsyncError(
      error,
      earningsAsync.stackTrace ??
          expensesAsync.stackTrace ??
          fuelAsync.stackTrace ??
          StackTrace.current,
    );
  }

  final earnings = _scoped(
    items: earningsAsync.valueOrNull ?? const [],
    vehicleId: scopedVehicleId,
    vehicleIdOf: (e) => e.vehicleId,
  );
  final expenses = _scoped(
    items: expensesAsync.valueOrNull ?? const [],
    vehicleId: scopedVehicleId,
    vehicleIdOf: (e) => e.vehicleId,
  );

  return AsyncData(
    PeriodComparisonCalculator.compare(
      period: period,
      reference: reference,
      earnings: earnings,
      expenses: expenses,
      fuelLogs: fuelAsync.valueOrNull ?? const [],
    ),
  );
});

/// Reutilizado pelos relatórios na seção de comparação.
final reportComparisonProvider =
    Provider<AsyncValue<PeriodComparisonResult>>((ref) {
  final period = ref.watch(reportPeriodProvider);
  final reference = ref.watch(analyticsComparisonReferenceProvider);
  final earningsAsync = ref.watch(earningsStreamProvider);
  final expensesAsync = ref.watch(expensesStreamProvider);
  final fuelAsync = ref.watch(activeVehicleFuelLogsProvider);
  final scopedVehicleId = ref.watch(scopedVehicleIdProvider);

  if (earningsAsync.isLoading ||
      expensesAsync.isLoading ||
      fuelAsync.isLoading) {
    return const AsyncLoading();
  }

  final error =
      earningsAsync.error ?? expensesAsync.error ?? fuelAsync.error;
  if (error != null) {
    return AsyncError(
      error,
      earningsAsync.stackTrace ??
          expensesAsync.stackTrace ??
          fuelAsync.stackTrace ??
          StackTrace.current,
    );
  }

  final earnings = _scoped(
    items: earningsAsync.valueOrNull ?? const [],
    vehicleId: scopedVehicleId,
    vehicleIdOf: (e) => e.vehicleId,
  );
  final expenses = _scoped(
    items: expensesAsync.valueOrNull ?? const [],
    vehicleId: scopedVehicleId,
    vehicleIdOf: (e) => e.vehicleId,
  );

  return AsyncData(
    PeriodComparisonCalculator.compare(
      period: period,
      reference: reference,
      earnings: earnings,
      expenses: expenses,
      fuelLogs: fuelAsync.valueOrNull ?? const [],
    ),
  );
});

final reportCategoryBreakdownProvider =
    Provider<AsyncValue<List<CategoryBreakdownSlice>>>((ref) {
  final period = ref.watch(reportPeriodProvider);
  final expensesAsync = ref.watch(expensesStreamProvider);
  final scopedVehicleId = ref.watch(scopedVehicleIdProvider);
  final range = dateRangeForGoalPeriod(period);

  return expensesAsync.whenData((expenses) {
    final scoped = _scoped(
      items: expenses,
      vehicleId: scopedVehicleId,
      vehicleIdOf: (e) => e.vehicleId,
    );
    return CategoryBreakdownCalculator.build(expenses: scoped, range: range);
  });
});
