import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../maintenance/presentation/providers/maintenance_providers.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../data/repositories/fuel_repository_impl.dart';
import '../../domain/entities/fuel_log_entity.dart';
import '../../domain/repositories/fuel_repository.dart';
import '../../domain/services/fuel_metrics_calculator.dart';
import '../../domain/usecases/fuel_usecases.dart';

final fuelRepositoryProvider = Provider<FuelRepository>((ref) {
  return FuelRepositoryImpl(
    maintenance: ref.watch(maintenanceRepositoryProvider),
    predictiveScheduler: ref.watch(predictiveMaintenanceSchedulerProvider),
  );
});

final fuelLogsStreamProvider =
    StreamProvider.family<List<FuelLogEntity>, String>((ref, vehicleId) {
  final watch = WatchFuelLogs(ref.watch(fuelRepositoryProvider));
  return watch(vehicleId: vehicleId);
});

final activeVehicleFuelLogsProvider =
    Provider<AsyncValue<List<FuelLogEntity>>>((ref) {
  final vehicle = ref.watch(activeVehicleProvider).valueOrNull;
  if (vehicle == null) return const AsyncData([]);

  return ref.watch(fuelLogsStreamProvider(vehicle.id));
});

final lastFuelLogProvider = Provider<AsyncValue<FuelLogEntity?>>((ref) {
  return ref.watch(activeVehicleFuelLogsProvider).whenData((logs) {
    if (logs.isEmpty) return null;
    return logs.first;
  });
});

final rollingKmPerLiterProvider = Provider<AsyncValue<double?>>((ref) {
  return ref.watch(activeVehicleFuelLogsProvider).whenData((logs) {
    return FuelMetricsCalculator.rollingAverageKmPerLiter(logs);
  });
});

final createFuelLogProvider = Provider<CreateFuelLog>((ref) {
  return CreateFuelLog(ref.watch(fuelRepositoryProvider));
});

final updateFuelLogProvider = Provider<UpdateFuelLog>((ref) {
  return UpdateFuelLog(ref.watch(fuelRepositoryProvider));
});

final deleteFuelLogProvider = Provider<DeleteFuelLog>((ref) {
  return DeleteFuelLog(ref.watch(fuelRepositoryProvider));
});

class FuelController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<FuelLogEntity?> save({
    String? fuelLogId,
    required FuelLogDraft draft,
  }) async {
    state = const AsyncLoading();
    FuelLogEntity? saved;
    state = await AsyncValue.guard(() async {
      if (fuelLogId == null) {
        saved = await ref.read(createFuelLogProvider)(draft);
      } else {
        saved = await ref.read(updateFuelLogProvider)(
          id: fuelLogId,
          draft: draft,
        );
      }
    });
    if (state.hasError) return null;
    return saved;
  }

  Future<bool> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteFuelLogProvider)(id);
    });
    return !state.hasError;
  }

  void clearError() => state = const AsyncData(null);
}

final fuelControllerProvider =
    NotifierProvider<FuelController, AsyncValue<void>>(FuelController.new);
