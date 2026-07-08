import '../entities/maintenance_entity.dart';

abstract interface class MaintenanceRepository {
  Stream<List<MaintenanceEntity>> watchMaintenance({required String vehicleId});

  Future<List<MaintenanceEntity>> fetchMaintenance({required String vehicleId});

  Future<MaintenanceEntity> createMaintenance(MaintenanceDraft draft);

  Future<MaintenanceEntity> updateMaintenance({
    required String id,
    required MaintenanceDraft draft,
  });

  Future<void> deleteMaintenance(String id);
}
