import '../../../../core/storage/cached_remote_watch.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../../../../core/storage/local_entity_cache.dart';
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
    LocalEntityCache? cache,
  })  : _remote = remote ?? MaintenanceRemoteDataSource(),
        _notifications =
            notifications ?? MaintenanceNotificationService.instance,
        _cache = cache ?? LocalEntityCache();

  final MaintenanceRemoteDataSource _remote;
  final MaintenanceNotificationService _notifications;
  final LocalEntityCache _cache;

  @override
  Stream<List<MaintenanceEntity>> watchMaintenance({
    required String vehicleId,
  }) {
    return watchCachedRemote(
      remote: _remote.watchMaintenance(),
      loadLocal: () => _loadLocal(vehicleId),
      mapRows: (rows) => rows
          .where((row) => row[MaintenanceSchema.vehicleId] == vehicleId)
          .map(MaintenanceMapper.fromRow)
          .toList(growable: false),
      persistRemote: (rows) => _cache.replaceAll(HiveBoxes.maintenance, rows),
    );
  }

  Future<List<MaintenanceEntity>> _loadLocal(String vehicleId) async {
    final rows = await _cache.readAll(HiveBoxes.maintenance);
    return rows
        .where((row) => row[MaintenanceSchema.vehicleId] == vehicleId)
        .map(MaintenanceMapper.fromRow)
        .toList(growable: false);
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
