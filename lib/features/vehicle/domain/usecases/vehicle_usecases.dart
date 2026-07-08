import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

class WatchVehicles {
  const WatchVehicles(this._repository);

  final VehicleRepository _repository;

  Stream<List<VehicleEntity>> call() => _repository.watchVehicles();
}

class FetchVehicles {
  const FetchVehicles(this._repository);

  final VehicleRepository _repository;

  Future<List<VehicleEntity>> call() => _repository.fetchVehicles();
}

class CreateVehicle {
  const CreateVehicle(this._repository);

  final VehicleRepository _repository;

  Future<VehicleEntity> call(VehicleDraft draft) =>
      _repository.createVehicle(draft);
}

class UpdateVehicle {
  const UpdateVehicle(this._repository);

  final VehicleRepository _repository;

  Future<VehicleEntity> call({
    required String id,
    required VehicleDraft draft,
  }) =>
      _repository.updateVehicle(id: id, draft: draft);
}

class DeleteVehicle {
  const DeleteVehicle(this._repository);

  final VehicleRepository _repository;

  Future<void> call(String id) => _repository.deleteVehicle(id);
}
