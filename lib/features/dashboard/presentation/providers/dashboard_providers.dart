import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../expenses/presentation/providers/expenses_providers.dart';
import '../../../fuel/presentation/providers/fuel_providers.dart';
import '../../../../shared/domain/models/dashboard_snapshot.dart';
import '../../../../shared/domain/models/period_summary.dart';
import '../../../../shared/domain/services/dashboard_aggregator.dart';

final dashboardSnapshotProvider = Provider<AsyncValue<DashboardSnapshot>>((ref) {
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

  return AsyncData(
    DashboardAggregator.build(
      earnings: earningsAsync.valueOrNull ?? const [],
      expenses: expensesAsync.valueOrNull ?? const [],
      fuelLogs: fuelAsync.valueOrNull ?? const [],
    ),
  );
});

final dashboardTodayProvider = Provider<AsyncValue<PeriodSummary>>((ref) {
  return ref.watch(dashboardSnapshotProvider).whenData((snapshot) => snapshot.today);
});

final dashboardMonthProvider = Provider<AsyncValue<PeriodSummary>>((ref) {
  return ref.watch(dashboardSnapshotProvider).whenData((snapshot) => snapshot.month);
});
