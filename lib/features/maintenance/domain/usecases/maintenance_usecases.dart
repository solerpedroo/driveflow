import '../entities/maintenance_entity.dart';
import '../repositories/maintenance_repository.dart';

class WatchMaintenance {
  const WatchMaintenance(this._repository);

  final MaintenanceRepository _repository;

  Stream<List<MaintenanceEntity>> call({required String vehicleId}) =>
      _repository.watchMaintenance(vehicleId: vehicleId);
}

class CreateMaintenance {
  const CreateMaintenance(this._repository);

  final MaintenanceRepository _repository;

  Future<MaintenanceEntity> call(MaintenanceDraft draft) =>
      _repository.createMaintenance(draft);
}

class UpdateMaintenance {
  const UpdateMaintenance(this._repository);

  final MaintenanceRepository _repository;

  Future<MaintenanceEntity> call({
    required String id,
    required MaintenanceDraft draft,
  }) =>
      _repository.updateMaintenance(id: id, draft: draft);
}

class DeleteMaintenance {
  const DeleteMaintenance(this._repository);

  final MaintenanceRepository _repository;

  Future<void> call(String id) => _repository.deleteMaintenance(id);
}
