import '../entities/fuel_log_entity.dart';
import '../repositories/fuel_repository.dart';

class WatchFuelLogs {
  const WatchFuelLogs(this._repository);

  final FuelRepository _repository;

  Stream<List<FuelLogEntity>> call({required String vehicleId}) =>
      _repository.watchFuelLogs(vehicleId: vehicleId);
}

class CreateFuelLog {
  const CreateFuelLog(this._repository);

  final FuelRepository _repository;

  Future<FuelLogEntity> call(FuelLogDraft draft) =>
      _repository.createFuelLog(draft);
}

class UpdateFuelLog {
  const UpdateFuelLog(this._repository);

  final FuelRepository _repository;

  Future<FuelLogEntity> call({
    required String id,
    required FuelLogDraft draft,
  }) =>
      _repository.updateFuelLog(id: id, draft: draft);
}

class DeleteFuelLog {
  const DeleteFuelLog(this._repository);

  final FuelRepository _repository;

  Future<void> call(String id) => _repository.deleteFuelLog(id);
}
