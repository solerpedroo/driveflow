import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../data/repositories/maintenance_repository_impl.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../../domain/services/maintenance_due_checker.dart';
import '../../domain/usecases/maintenance_usecases.dart';

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  return MaintenanceRepositoryImpl();
});

final maintenanceStreamProvider =
    StreamProvider.family<List<MaintenanceEntity>, String>((ref, vehicleId) {
  final watch = WatchMaintenance(ref.watch(maintenanceRepositoryProvider));
  return watch(vehicleId: vehicleId);
});

final activeVehicleMaintenanceProvider =
    Provider<AsyncValue<List<MaintenanceEntity>>>((ref) {
  final vehicle = ref.watch(activeVehicleProvider).valueOrNull;
  if (vehicle == null) return const AsyncData([]);

  return ref.watch(maintenanceStreamProvider(vehicle.id));
});

class MaintenanceAlert {
  const MaintenanceAlert({
    required this.record,
    required this.status,
  });

  final MaintenanceEntity record;
  final MaintenanceDueStatus status;
}

final maintenanceAlertsProvider =
    Provider<AsyncValue<List<MaintenanceAlert>>>((ref) {
  final recordsAsync = ref.watch(activeVehicleMaintenanceProvider);
  final odometer = ref.watch(activeVehicleProvider).valueOrNull?.odometerKm;

  return recordsAsync.whenData((records) {
    if (odometer == null) return const [];
    return records
        .map((record) {
          final status = MaintenanceDueChecker.check(
            record: record,
            currentOdometerKm: odometer,
          );
          if (status == MaintenanceDueStatus.ok) return null;
          return MaintenanceAlert(record: record, status: status);
        })
        .whereType<MaintenanceAlert>()
        .toList(growable: false);
  });
});

final maintenanceAlertCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(maintenanceAlertsProvider).whenData((alerts) => alerts.length);
});

final createMaintenanceProvider = Provider<CreateMaintenance>((ref) {
  return CreateMaintenance(ref.watch(maintenanceRepositoryProvider));
});

final updateMaintenanceProvider = Provider<UpdateMaintenance>((ref) {
  return UpdateMaintenance(ref.watch(maintenanceRepositoryProvider));
});

final deleteMaintenanceProvider = Provider<DeleteMaintenance>((ref) {
  return DeleteMaintenance(ref.watch(maintenanceRepositoryProvider));
});

class MaintenanceController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<MaintenanceEntity?> save({
    String? maintenanceId,
    required MaintenanceDraft draft,
  }) async {
    state = const AsyncLoading();
    MaintenanceEntity? saved;
    state = await AsyncValue.guard(() async {
      if (maintenanceId == null) {
        saved = await ref.read(createMaintenanceProvider)(draft);
      } else {
        saved = await ref.read(updateMaintenanceProvider)(
          id: maintenanceId,
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
      await ref.read(deleteMaintenanceProvider)(id);
    });
    return !state.hasError;
  }

  void clearError() => state = const AsyncData(null);
}

final maintenanceControllerProvider =
    NotifierProvider<MaintenanceController, AsyncValue<void>>(
  MaintenanceController.new,
);
