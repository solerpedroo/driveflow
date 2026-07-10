import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../earnings/domain/entities/earning_entity.dart';
import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../integrations/domain/services/platform_analytics_breakdown.dart';
import '../../../integrations/presentation/providers/platform_trips_providers.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../expenses/presentation/providers/expenses_providers.dart';
import '../../../fuel/domain/entities/fuel_log_entity.dart';
import '../../../fuel/presentation/providers/fuel_providers.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../../../reports/presentation/providers/reports_providers.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../../../core/utils/vehicle_scope_filter.dart';
import '../../domain/entities/analytics_enums.dart';
import '../../domain/entities/category_breakdown_slice.dart';
import '../../domain/entities/period_comparison_result.dart';
import '../../domain/entities/profit_forecast_result.dart';
import '../../domain/services/category_breakdown_calculator.dart';
import '../../domain/services/period_comparison_calculator.dart';
import '../../domain/services/profit_forecast_calculator.dart';
import '../../domain/services/profit_trend_calculator.dart';
import '../../../../shared/domain/models/daily_profit_point.dart';

final analyticsTrendWindowProvider =
    StateProvider<TrendWindow>((ref) => TrendWindow.days30);

final analyticsComparisonReferenceProvider =
    StateProvider<ComparisonReference>((ref) => ComparisonReference.previousPeriod);

final analyticsPeriodProvider =
    StateProvider<GoalPeriod>((ref) => GoalPeriod.monthly);

final analyticsProfitForecastProvider =
    Provider<AsyncValue<ProfitForecastResult>>((ref) {
  final earningsAsync = ref.watch(earningsStreamProvider);
  final expensesAsync = ref.watch(expensesStreamProvider);
  final scopedVehicleId = ref.watch(scopedVehicleIdProvider);

  if (earningsAsync.isLoading || expensesAsync.isLoading) {
    return const AsyncLoading();
  }

  final error = earningsAsync.error ?? expensesAsync.error;
  if (error != null) {
    return AsyncError(
      error,
      earningsAsync.stackTrace ??
          expensesAsync.stackTrace ??
          StackTrace.current,
    );
  }

  final earnings = _scoped(
    items: earningsAsync.valueOrNull ?? const <EarningEntity>[],
    vehicleId: scopedVehicleId,
    vehicleIdOf: (e) => e.vehicleId,
  );
  final expenses = _scoped(
    items: expensesAsync.valueOrNull ?? const <ExpenseEntity>[],
    vehicleId: scopedVehicleId,
    vehicleIdOf: (e) => e.vehicleId,
  );

  return AsyncData(
    ProfitForecastCalculator.compute(
      earnings: earnings,
      expenses: expenses,
    ),
  );
});

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
    items: earningsAsync.valueOrNull ?? const <EarningEntity>[],
    vehicleId: scopedVehicleId,
    vehicleIdOf: (e) => e.vehicleId,
  );
  final expenses = _scoped(
    items: expensesAsync.valueOrNull ?? const <ExpenseEntity>[],
    vehicleId: scopedVehicleId,
    vehicleIdOf: (e) => e.vehicleId,
  );

  return AsyncData(
    PeriodComparisonCalculator.compare(
      period: period,
      reference: reference,
      earnings: earnings,
      expenses: expenses,
      fuelLogs: fuelAsync.valueOrNull ?? const <FuelLogEntity>[],
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
    items: earningsAsync.valueOrNull ?? const <EarningEntity>[],
    vehicleId: scopedVehicleId,
    vehicleIdOf: (e) => e.vehicleId,
  );
  final expenses = _scoped(
    items: expensesAsync.valueOrNull ?? const <ExpenseEntity>[],
    vehicleId: scopedVehicleId,
    vehicleIdOf: (e) => e.vehicleId,
  );

  return AsyncData(
    PeriodComparisonCalculator.compare(
      period: period,
      reference: reference,
      earnings: earnings,
      expenses: expenses,
      fuelLogs: fuelAsync.valueOrNull ?? const <FuelLogEntity>[],
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

final analyticsPlatformBreakdownProvider =
    Provider<AsyncValue<List<PlatformRevenueSlice>>>((ref) {
  final earnings = ref.watch(earningsStreamProvider);
  final trips = ref.watch(platformTripsStreamProvider);
  final period = ref.watch(analyticsPeriodProvider);
  final scopedVehicleId = ref.watch(scopedVehicleIdProvider);
  final range = dateRangeForGoalPeriod(period);

  if (earnings.isLoading || trips.isLoading) {
    return const AsyncLoading();
  }

  final error = earnings.error ?? trips.error;
  if (error != null) {
    return AsyncError(
      error,
      earnings.stackTrace ?? trips.stackTrace ?? StackTrace.current,
    );
  }

  final scopedEarnings = _scoped(
    items: earnings.valueOrNull ?? const <EarningEntity>[],
    vehicleId: scopedVehicleId,
    vehicleIdOf: (e) => e.vehicleId,
  );
  final scopedTrips = _scoped(
    items: trips.valueOrNull ?? const [],
    vehicleId: scopedVehicleId,
    vehicleIdOf: (t) => t.vehicleId,
  );

  final filteredEarnings = scopedEarnings
      .where(
        (e) => !e.date.isBefore(range.start) && !e.date.isAfter(range.end),
      )
      .toList();
  final filteredTrips = scopedTrips
      .where(
        (t) =>
            !t.startedAt.isBefore(range.start) &&
            !t.startedAt.isAfter(range.end),
      )
      .toList();

  return AsyncData(
    PlatformAnalyticsBreakdown.fromTripsOrEarnings(
      trips: filteredTrips,
      earnings: filteredEarnings,
    ),
  );
});
