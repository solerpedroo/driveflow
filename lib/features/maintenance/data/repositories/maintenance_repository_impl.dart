import '../../../../core/storage/cached_remote_watch.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../../../../core/storage/local_entity_cache.dart';
import '../../../../core/services/maintenance_notification_service.dart';
import '../../../expenses/data/datasources/expenses_remote_datasource.dart';
import '../../../expenses/data/schema/expenses_schema.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../../domain/services/maintenance_expense_linker.dart';
import '../datasources/maintenance_remote_datasource.dart';
import '../mappers/maintenance_mapper.dart';
import '../schema/maintenance_schema.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  MaintenanceRepositoryImpl({
    MaintenanceRemoteDataSource? remote,
    ExpensesRemoteDataSource? expenses,
    MaintenanceNotificationService? notifications,
    LocalEntityCache? cache,
  })  : _remote = remote ?? MaintenanceRemoteDataSource(),
        _expenses = expenses ?? ExpensesRemoteDataSource(),
        _notifications =
            notifications ?? MaintenanceNotificationService.instance,
        _cache = cache ?? LocalEntityCache();

  final MaintenanceRemoteDataSource _remote;
  final ExpensesRemoteDataSource _expenses;
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
    await _syncExpense(entity);
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
    await _syncExpense(entity);
    await _notifications.syncReminder(entity);
    return entity;
  }

  @override
  Future<void> deleteMaintenance(String id) async {
    await _notifications.cancelReminder(id);
    await _expenses.deleteByDescriptionContains(
      MaintenanceExpenseLinker.tokenFor(id),
    );
    await _remote.deleteMaintenance(id);
  }

  Future<void> _syncExpense(MaintenanceEntity entity) async {
    if (entity.cost <= 0) {
      await _expenses.deleteByDescriptionContains(
        MaintenanceExpenseLinker.tokenFor(entity.id),
      );
      return;
    }

    final description = MaintenanceExpenseLinker.description(
      maintenanceId: entity.id,
      typeLabel: entity.type.label,
      notes: entity.notes,
    );
    final token = MaintenanceExpenseLinker.tokenFor(entity.id);
    final existing = await _expenses.findByDescriptionContains(token);

    if (existing == null) {
      await _expenses.createExpense(
        draft: ExpenseDraft(
          category: ExpenseCategory.mechanic,
          amount: entity.cost,
          date: entity.serviceDate,
          description: description,
          vehicleId: entity.vehicleId,
        ),
      );
    } else {
      await _expenses.updateByDescriptionContains(
        token,
        values: {
          ExpensesSchema.amount: entity.cost,
          ExpensesSchema.description: description,
          ExpensesSchema.date: entity.serviceDate.toUtc().toIso8601String(),
          ExpensesSchema.vehicleId: entity.vehicleId,
          ExpensesSchema.category: ExpenseCategory.mechanic.value,
        },
      );
    }
  }
}
