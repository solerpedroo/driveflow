import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/transaction_filters.dart';
import '../../../../core/utils/vehicle_scope_filter.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../../../fuel/domain/entities/fuel_log_entity.dart';
import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../expenses/presentation/providers/expenses_providers.dart';
import '../../../fuel/presentation/providers/fuel_providers.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../shared/domain/services/profit_calculator.dart';
import '../../domain/entities/report_snapshot.dart';
import '../../domain/services/report_exporter.dart';
import '../../../analytics/presentation/providers/analytics_providers.dart';

final reportPeriodProvider =
    StateProvider<GoalPeriod>((ref) => GoalPeriod.monthly);

final reportSnapshotProvider = Provider<AsyncValue<ReportSnapshot>>((ref) {
  final period = ref.watch(reportPeriodProvider);
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

  final earnings = VehicleScopeFilter.byVehicle(
    items: earningsAsync.valueOrNull ?? const <EarningEntity>[],
    vehicleId: scopedVehicleId,
    vehicleIdOf: (e) => e.vehicleId,
  );
  final expenses = VehicleScopeFilter.byVehicle(
    items: expensesAsync.valueOrNull ?? const <ExpenseEntity>[],
    vehicleId: scopedVehicleId,
    vehicleIdOf: (e) => e.vehicleId,
  );

  final range = dateRangeForGoalPeriod(period);
  final summary = ProfitCalculator.summarize(
    earnings: earnings,
    expenses: expenses,
    fuelLogs: fuelAsync.valueOrNull ?? const <FuelLogEntity>[],
    range: range,
  );

  return AsyncData(
    ReportSnapshot(
      period: period,
      summary: summary,
      generatedAt: DateTime.now(),
    ),
  );
});

final reportEarningsProvider = Provider<AsyncValue<List<EarningEntity>>>((ref) {
  final period = ref.watch(reportPeriodProvider);
  final earningsAsync = ref.watch(earningsStreamProvider);
  final scopedVehicleId = ref.watch(scopedVehicleIdProvider);
  final range = dateRangeForGoalPeriod(period);

  return earningsAsync.whenData((items) {
    final scoped = VehicleScopeFilter.byVehicle(
      items: items,
      vehicleId: scopedVehicleId,
      vehicleIdOf: (e) => e.vehicleId,
    );
    return TransactionFilters.byDateRange(scoped, range, (e) => e.date);
  });
});

final reportExpensesProvider = Provider<AsyncValue<List<ExpenseEntity>>>((ref) {
  final period = ref.watch(reportPeriodProvider);
  final expensesAsync = ref.watch(expensesStreamProvider);
  final scopedVehicleId = ref.watch(scopedVehicleIdProvider);
  final range = dateRangeForGoalPeriod(period);

  return expensesAsync.whenData((items) {
    final scoped = VehicleScopeFilter.byVehicle(
      items: items,
      vehicleId: scopedVehicleId,
      vehicleIdOf: (e) => e.vehicleId,
    );
    return TransactionFilters.byDateRange(scoped, range, (e) => e.date);
  });
});

class ReportsController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> exportPdf() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final snapshot = ref.read(reportSnapshotProvider).requireValue;
      final earnings = ref.read(reportEarningsProvider).requireValue;
      final expenses = ref.read(reportExpensesProvider).requireValue;
      final comparison = ref.read(reportComparisonProvider).valueOrNull;
      await ReportExporter.sharePdf(
        snapshot: snapshot,
        earnings: earnings,
        expenses: expenses,
        comparison: comparison,
      );
      DriveFlowAnalytics.logEvent('report_exported', {'format': 'pdf'});
    });
    return !state.hasError;
  }

  Future<bool> exportCsv() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final snapshot = ref.read(reportSnapshotProvider).requireValue;
      final earnings = ref.read(reportEarningsProvider).requireValue;
      final expenses = ref.read(reportExpensesProvider).requireValue;
      final comparison = ref.read(reportComparisonProvider).valueOrNull;
      await ReportExporter.shareCsv(
        snapshot: snapshot,
        earnings: earnings,
        expenses: expenses,
        comparison: comparison,
      );
      DriveFlowAnalytics.logEvent('report_exported', {'format': 'csv'});
    });
    return !state.hasError;
  }

  void clearError() => state = const AsyncData(null);
}

final reportsControllerProvider =
    NotifierProvider<ReportsController, AsyncValue<void>>(ReportsController.new);
