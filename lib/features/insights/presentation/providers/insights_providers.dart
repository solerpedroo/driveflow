import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/vehicle_scope_filter.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../expenses/presentation/providers/expenses_providers.dart';
import '../../../fuel/presentation/providers/fuel_providers.dart';
import '../../../goals/presentation/providers/goals_providers.dart';
import '../../../maintenance/presentation/providers/maintenance_providers.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../domain/entities/earning_time_slot.dart';
import '../../domain/entities/maintenance_prediction.dart';
import '../../domain/entities/weekly_goal_projection.dart';
import '../../domain/services/earnings_heatmap_builder.dart';
import '../../domain/services/maintenance_predictor.dart';
import '../../domain/services/weekly_goal_projection_calculator.dart';

/// Quantidade de janelas exibidas no card de melhor horário.
enum InsightsSlotsLimit {
  top3(3, 'Top 3'),
  top5(5, 'Top 5'),
  top10(10, 'Top 10');

  const InsightsSlotsLimit(this.count, this.label);

  final int count;
  final String label;
}

final insightsSlotsLimitProvider =
    StateProvider<InsightsSlotsLimit>((ref) => InsightsSlotsLimit.top5);

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

final maintenancePredictionsProvider =
    Provider<AsyncValue<List<MaintenancePrediction>>>((ref) {
  final maintenanceAsync = ref.watch(activeVehicleMaintenanceProvider);
  final fuelAsync = ref.watch(activeVehicleFuelLogsProvider);
  final odometer = ref.watch(activeVehicleProvider).valueOrNull?.odometerKm;

  if (maintenanceAsync.isLoading || fuelAsync.isLoading) {
    return const AsyncLoading();
  }

  final error = maintenanceAsync.error ?? fuelAsync.error;
  if (error != null) {
    return AsyncError(
      error,
      maintenanceAsync.stackTrace ??
          fuelAsync.stackTrace ??
          StackTrace.current,
    );
  }

  if (odometer == null) return const AsyncData([]);

  return AsyncData(
    MaintenancePredictor.predictAll(
      records: maintenanceAsync.valueOrNull ?? const [],
      fuelLogs: fuelAsync.valueOrNull ?? const [],
      currentOdometerKm: odometer,
    ),
  );
});

final topMaintenancePredictionProvider =
    Provider<AsyncValue<MaintenancePrediction?>>((ref) {
  return ref.watch(maintenancePredictionsProvider).whenData((predictions) {
    if (predictions.isEmpty) return null;
    predictions.sort((a, b) {
      final aDays = a.daysUntilDue ?? 9999;
      final bDays = b.daysUntilDue ?? 9999;
      return aDays.compareTo(bDays);
    });
    return predictions.first;
  });
});

final earningsHeatmapProvider =
    Provider<AsyncValue<List<EarningTimeSlot>>>((ref) {
  final earningsAsync = ref.watch(earningsStreamProvider);
  final scopedVehicleId = ref.watch(scopedVehicleIdProvider);

  return earningsAsync.whenData((earnings) {
    final scoped = _scoped(
      items: earnings,
      vehicleId: scopedVehicleId,
      vehicleIdOf: (e) => e.vehicleId,
    );
    return EarningsHeatmapBuilder.build(earnings: scoped);
  });
});

final topEarningSlotsProvider =
    Provider<AsyncValue<List<EarningTimeSlot>>>((ref) {
  final earningsAsync = ref.watch(earningsStreamProvider);
  final scopedVehicleId = ref.watch(scopedVehicleIdProvider);

  return earningsAsync.whenData((earnings) {
    final scoped = _scoped(
      items: earnings,
      vehicleId: scopedVehicleId,
      vehicleIdOf: (e) => e.vehicleId,
    );
    return EarningsHeatmapBuilder.topSlots(earnings: scoped);
  });
});

final weeklyGoalProjectionProvider =
    Provider<AsyncValue<WeeklyGoalProjection>>((ref) {
  final goals = ref.watch(goalsStreamProvider).valueOrNull;
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
    WeeklyGoalProjectionCalculator.compute(
      goals: goals,
      earnings: earnings,
      expenses: expenses,
    ),
  );
});
