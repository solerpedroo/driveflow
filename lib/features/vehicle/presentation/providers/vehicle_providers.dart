import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/providers/sync_providers.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../domain/services/vehicle_default_resolver.dart';
import '../../domain/usecases/vehicle_usecases.dart';
import '../../data/repositories/vehicle_repository_impl.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepositoryImpl(
    cache: ref.watch(localEntityCacheProvider),
    syncQueue: ref.watch(pendingSyncQueueProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    syncWorker: ref.watch(syncWorkerProvider),
  );
});

final vehiclesStreamProvider =
    StreamProvider.autoDispose<List<VehicleEntity>>((ref) {
  final watch = WatchVehicles(ref.watch(vehicleRepositoryProvider));
  return watch();
});

/// Alias semântico — lista completa de veículos do usuário.
final vehiclesListProvider = vehiclesStreamProvider;

/// ID do veículo persistido localmente (seleção do motorista).
final activeVehicleIdProvider =
    NotifierProvider<ActiveVehicleIdNotifier, String?>(
  ActiveVehicleIdNotifier.new,
);

class ActiveVehicleIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    return ref.watch(vehicleRepositoryProvider).readActiveVehicleId();
  }

  Future<void> select(String? vehicleId) async {
    await ref.read(vehicleRepositoryProvider).setActiveVehicleId(vehicleId);
    state = vehicleId;
  }
}

/// null = todos os veículos (ganhos/despesas); fuel/manutenção usam [activeVehicleProvider].
final scopedVehicleIdProvider = StateProvider<String?>((ref) => null);

final activeVehicleProvider = Provider<AsyncValue<VehicleEntity?>>((ref) {
  final vehiclesAsync = ref.watch(vehiclesStreamProvider);
  final scopedId = ref.watch(scopedVehicleIdProvider);
  final storedId = ref.watch(activeVehicleIdProvider);

  return vehiclesAsync.whenData((vehicles) {
    final preferredId = scopedId ?? storedId;
    return VehicleDefaultResolver.resolve(
      vehicles: vehicles,
      preferredId: preferredId,
    );
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

final deleteVehicleProvider = Provider<DeleteVehicle>((ref) {
  return DeleteVehicle(ref.watch(vehicleRepositoryProvider));
});

final setDefaultVehicleProvider = Provider<SetDefaultVehicle>((ref) {
  return SetDefaultVehicle(ref.watch(vehicleRepositoryProvider));
});

final setActiveVehicleProvider = Provider<SetActiveVehicle>((ref) {
  return SetActiveVehicle(ref.watch(vehicleRepositoryProvider));
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
    ref.invalidate(vehiclesStreamProvider);
    return saved;
  }

  Future<bool> delete(String vehicleId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteVehicleProvider)(vehicleId);
      final activeId = ref.read(activeVehicleIdProvider);
      if (activeId == vehicleId) {
        ref.read(scopedVehicleIdProvider.notifier).state = null;
      }
    });
    return !state.hasError;
  }

  Future<bool> setDefault(String vehicleId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(setDefaultVehicleProvider)(vehicleId);
      await ref.read(activeVehicleIdProvider.notifier).select(vehicleId);
      ref.read(scopedVehicleIdProvider.notifier).state = vehicleId;
    });
    return !state.hasError;
  }

  Future<void> selectScope({required String? vehicleId}) async {
    ref.read(scopedVehicleIdProvider.notifier).state = vehicleId;
    if (vehicleId != null) {
      await ref.read(activeVehicleIdProvider.notifier).select(vehicleId);
    }
  }

  void clearError() => state = const AsyncData(null);
}

final vehicleControllerProvider =
    NotifierProvider<VehicleController, AsyncValue<void>>(VehicleController.new);
