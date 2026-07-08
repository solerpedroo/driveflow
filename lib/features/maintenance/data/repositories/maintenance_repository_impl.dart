import '../../../../core/services/maintenance_notification_service.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../datasources/maintenance_remote_datasource.dart';
import '../mappers/maintenance_mapper.dart';
import '../schema/maintenance_schema.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  MaintenanceRepositoryImpl({
    MaintenanceRemoteDataSource? remote,
    MaintenanceNotificationService? notifications,
  })  : _remote = remote ?? MaintenanceRemoteDataSource(),
        _notifications =
            notifications ?? MaintenanceNotificationService.instance;

  final MaintenanceRemoteDataSource _remote;
  final MaintenanceNotificationService _notifications;

  @override
  Stream<List<MaintenanceEntity>> watchMaintenance({
    required String vehicleId,
  }) {
    return _remote.watchMaintenance().map(
          (rows) => rows
              .where((row) => row[MaintenanceSchema.vehicleId] == vehicleId)
              .map(MaintenanceMapper.fromRow)
              .toList(growable: false),
        );
  }

  @override
  Future<List<MaintenanceEntity>> fetchMaintenance({
    required String vehicleId,
  }) async {
    final rows = await _remote.fetchMaintenance(vehicleId: vehicleId);
    return rows.map(MaintenanceMapper.fromRow).toList(growable: false);
  }

  @override
  Future<MaintenanceEntity> createMaintenance(MaintenanceDraft draft) async {
    final row = await _remote.createMaintenance(draft: draft);
    final entity = MaintenanceMapper.fromRow(row);
    await _notifications.syncReminder(entity);
    return entity;
  }

  @override
  Future<MaintenanceEntity> updateMaintenance({
    required String id,
    required MaintenanceDraft draft,
  }) async {
    final row = await _remote.updateMaintenance(id: id, draft: draft);
    final entity = MaintenanceMapper.fromRow(row);
    await _notifications.syncReminder(entity);
    return entity;
  }

  @override
  Future<void> deleteMaintenance(String id) async {
    await _notifications.cancelReminder(id);
    await _remote.deleteMaintenance(id);
  }
}
