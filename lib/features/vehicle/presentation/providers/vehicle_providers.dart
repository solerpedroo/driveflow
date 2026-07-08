import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/vehicle_repository_impl.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../domain/usecases/vehicle_usecases.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepositoryImpl();
});

final vehiclesStreamProvider = StreamProvider<List<VehicleEntity>>((ref) {
  final watch = WatchVehicles(ref.watch(vehicleRepositoryProvider));
  return watch();
});

final activeVehicleProvider = Provider<AsyncValue<VehicleEntity?>>((ref) {
  return ref.watch(vehiclesStreamProvider).whenData((vehicles) {
    if (vehicles.isEmpty) return null;
    return vehicles.first;
  });
});

final hasVehicleProvider = Provider<AsyncValue<bool>>((ref) {
  return ref.watch(vehiclesStreamProvider).whenData((v) => v.isNotEmpty);
});

final createVehicleProvider = Provider<CreateVehicle>((ref) {
  return CreateVehicle(ref.watch(vehicleRepositoryProvider));
});

final updateVehicleProvider = Provider<UpdateVehicle>((ref) {
  return UpdateVehicle(ref.watch(vehicleRepositoryProvider));
});

/// Controller para mutações de veículo.
class VehicleController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<VehicleEntity?> save({
    String? vehicleId,
    required VehicleDraft draft,
  }) async {
    state = const AsyncLoading();
    VehicleEntity? saved;
    state = await AsyncValue.guard(() async {
      if (vehicleId == null) {
        saved = await ref.read(createVehicleProvider)(draft);
      } else {
        saved = await ref.read(updateVehicleProvider)(
          id: vehicleId,
          draft: draft,
        );
      }
    });
    if (state.hasError) return null;
    return saved;
  }

  void clearError() => state = const AsyncData(null);
}

final vehicleControllerProvider =
    NotifierProvider<VehicleController, AsyncValue<void>>(VehicleController.new);
