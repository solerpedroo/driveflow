import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/transaction_filters.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../expenses/presentation/providers/expenses_providers.dart';
import '../../../fuel/presentation/providers/fuel_providers.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../shared/domain/services/profit_calculator.dart';
import '../../domain/entities/report_snapshot.dart';
import '../../domain/services/report_exporter.dart';

final reportPeriodProvider =
    StateProvider<GoalPeriod>((ref) => GoalPeriod.monthly);

final reportSnapshotProvider = Provider<AsyncValue<ReportSnapshot>>((ref) {
  final period = ref.watch(reportPeriodProvider);
  final earningsAsync = ref.watch(earningsStreamProvider);
  final expensesAsync = ref.watch(expensesStreamProvider);
  final fuelAsync = ref.watch(activeVehicleFuelLogsProvider);

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

  final range = dateRangeForGoalPeriod(period);
  final summary = ProfitCalculator.summarize(
    earnings: earningsAsync.valueOrNull ?? const [],
    expenses: expensesAsync.valueOrNull ?? const [],
    fuelLogs: fuelAsync.valueOrNull ?? const [],
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
  final range = dateRangeForGoalPeriod(period);

  return earningsAsync.whenData(
    (items) => TransactionFilters.byDateRange(items, range, (e) => e.date),
  );
});

final reportExpensesProvider = Provider<AsyncValue<List<ExpenseEntity>>>((ref) {
  final period = ref.watch(reportPeriodProvider);
  final expensesAsync = ref.watch(expensesStreamProvider);
  final range = dateRangeForGoalPeriod(period);

  return expensesAsync.whenData(
    (items) => TransactionFilters.byDateRange(items, range, (e) => e.date),
  );
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
      await ReportExporter.sharePdf(
        snapshot: snapshot,
        earnings: earnings,
        expenses: expenses,
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
      await ReportExporter.shareCsv(
        snapshot: snapshot,
        earnings: earnings,
        expenses: expenses,
      );
      DriveFlowAnalytics.logEvent('report_exported', {'format': 'csv'});
    });
    return !state.hasError;
  }

  void clearError() => state = const AsyncData(null);
}

final reportsControllerProvider =
    NotifierProvider<ReportsController, AsyncValue<void>>(ReportsController.new);
