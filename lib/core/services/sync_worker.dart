import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/shift/data/datasources/shift_sessions_remote_datasource.dart';
import '../../features/shift/data/mappers/shift_sessions_mapper.dart';
import '../../features/earnings/data/datasources/earnings_remote_datasource.dart';
import '../../features/earnings/data/mappers/earnings_mapper.dart';
import '../../features/expenses/data/datasources/expenses_remote_datasource.dart';
import '../../features/expenses/data/mappers/expenses_mapper.dart';
import '../../features/vehicle/data/datasources/vehicle_remote_datasource.dart';
import '../../features/vehicle/data/mappers/vehicle_mapper.dart';
import '../storage/hive_boxes.dart';
import '../storage/local_entity_cache.dart';
import '../storage/pending_sync_operation.dart';
import '../storage/pending_sync_queue.dart';
import '../utils/local_id_generator.dart';
import 'connectivity_service.dart';
import 'sync_status.dart';

/// Processa a fila offline com retry exponencial.
class SyncWorker {
  SyncWorker({
    ConnectivityService? connectivity,
    PendingSyncQueue? queue,
    LocalEntityCache? cache,
    EarningsRemoteDataSource? earningsRemote,
    ExpensesRemoteDataSource? expensesRemote,
    VehicleRemoteDataSource? vehiclesRemote,
    ShiftSessionsRemoteDataSource? shiftSessionsRemote,
  })  : _connectivity = connectivity ?? ConnectivityService(),
        _queue = queue ?? PendingSyncQueue(),
        _cache = cache ?? LocalEntityCache(),
        _earningsRemote = earningsRemote ?? EarningsRemoteDataSource(),
        _expensesRemote = expensesRemote ?? ExpensesRemoteDataSource(),
        _vehiclesRemote = vehiclesRemote ?? VehicleRemoteDataSource(),
        _shiftSessionsRemote = shiftSessionsRemote ?? ShiftSessionsRemoteDataSource();

  final ConnectivityService _connectivity;
  final PendingSyncQueue _queue;
  final LocalEntityCache _cache;
  final EarningsRemoteDataSource _earningsRemote;
  final ExpensesRemoteDataSource _expensesRemote;
  final VehicleRemoteDataSource _vehiclesRemote;
  final ShiftSessionsRemoteDataSource _shiftSessionsRemote;

  final _statusController = StreamController<SyncStatus>.broadcast();
  StreamSubscription<bool>? _connectivitySub;
  var _processing = false;

  Stream<SyncStatus> get statusStream => _statusController.stream;

  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;

  void start() {
    _setStatus(SyncStatus.idle);
    _connectivitySub ??= _connectivity.onOnlineChanged.listen((online) {
      if (online) {
        unawaited(processQueue());
      } else {
        _setStatus(SyncStatus.offline);
      }
    });
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    if (await _connectivity.isOnline) {
      await processQueue();
    } else {
      _setStatus(SyncStatus.offline);
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
    _statusController.close();
  }

  Future<void> processQueue() async {
    if (_processing) return;
    if (!await _connectivity.isOnline) {
      _setStatus(SyncStatus.offline);
      return;
    }

    _processing = true;
    _setStatus(SyncStatus.syncing);

    try {
      while (await _connectivity.isOnline) {
        final operation = await _queue.peek();
        if (operation == null) break;

        try {
          await _execute(operation);
          await _queue.dequeue(operation.id);
        } on Object catch (error, stackTrace) {
          if (kDebugMode) {
            debugPrint(
              'DriveFlow sync failed (${operation.entity}/${operation.action}): '
              '$error\n$stackTrace',
            );
          }
          final nextAttempts = operation.attempts + 1;
          if (nextAttempts >= 8) {
            await _queue.dequeue(operation.id);
            _setStatus(SyncStatus.failed);
          } else {
            await _queue.replace(operation.copyWith(attempts: nextAttempts));
            // Sai do loop — próxima tentativa no próximo processQueue / reconnect.
            break;
          }
        }
      }
    } finally {
      _processing = false;
      final online = await _connectivity.isOnline;
      _setStatus(online ? SyncStatus.idle : SyncStatus.offline);
    }
  }

  Future<void> _execute(PendingSyncOperation operation) async {
    switch (operation.entity) {
      case HiveBoxes.earnings:
        await _syncEarning(operation);
      case HiveBoxes.expenses:
        await _syncExpense(operation);
      case HiveBoxes.vehicles:
        await _syncVehicle(operation);
      case HiveBoxes.shiftHistory:
        await _syncShiftHistory(operation);
      default:
        throw StateError(
          'Entidade de sync não suportada: ${operation.entity}',
        );
    }
  }

  Future<void> _syncEarning(PendingSyncOperation operation) async {
    switch (operation.action) {
      case SyncAction.create:
        final draft = EarningsMapper.draftFromJson(operation.payload);
        final row = await _earningsRemote.createEarning(draft: draft);
        await _cache.replaceId(
          HiveBoxes.earnings,
          oldId: operation.entityId,
          newRow: row,
        );
      case SyncAction.update:
        if (LocalIdGenerator.isLocal(operation.entityId)) return;
        final draft = EarningsMapper.draftFromJson(operation.payload);
        await _earningsRemote.updateEarning(
          id: operation.entityId,
          draft: draft,
        );
      case SyncAction.delete:
        if (LocalIdGenerator.isLocal(operation.entityId)) return;
        await _earningsRemote.deleteEarning(operation.entityId);
    }
  }

  Future<void> _syncExpense(PendingSyncOperation operation) async {
    switch (operation.action) {
      case SyncAction.create:
        final draft = ExpensesMapper.draftFromJson(operation.payload);
        final row = await _expensesRemote.createExpense(draft: draft);
        await _cache.replaceId(
          HiveBoxes.expenses,
          oldId: operation.entityId,
          newRow: row,
        );
      case SyncAction.update:
        if (LocalIdGenerator.isLocal(operation.entityId)) return;
        final draft = ExpensesMapper.draftFromJson(operation.payload);
        await _expensesRemote.updateExpense(
          id: operation.entityId,
          draft: draft,
        );
      case SyncAction.delete:
        if (LocalIdGenerator.isLocal(operation.entityId)) return;
        await _expensesRemote.deleteExpense(operation.entityId);
    }
  }

  Future<void> _syncVehicle(PendingSyncOperation operation) async {
    switch (operation.action) {
      case SyncAction.create:
        final draft = VehicleMapper.draftFromJson(operation.payload);
        final row = await _vehiclesRemote.createVehicle(draft: draft);
        await _cache.replaceId(
          HiveBoxes.vehicles,
          oldId: operation.entityId,
          newRow: row,
        );
      case SyncAction.update:
        if (LocalIdGenerator.isLocal(operation.entityId)) return;
        final draft = VehicleMapper.draftFromJson(operation.payload);
        await _vehiclesRemote.updateVehicle(
          id: operation.entityId,
          draft: draft,
        );
      case SyncAction.delete:
        if (LocalIdGenerator.isLocal(operation.entityId)) return;
        final promoteId = operation.payload['promote_default_id'] as String?;
        await _vehiclesRemote.deleteVehicle(operation.entityId);
        if (promoteId != null) {
          await _vehiclesRemote.setDefaultVehicle(promoteId);
        }
    }
  }

  Future<void> _syncShiftHistory(PendingSyncOperation operation) async {
    if (operation.action != SyncAction.create) return;

    final entry = ShiftSessionsMapper.fromRow(operation.payload);
    final row = await _shiftSessionsRemote.createCompleted(entry: entry);
    await _cache.replaceId(
      HiveBoxes.shiftHistory,
      oldId: operation.entityId,
      newRow: row,
    );
  }

  void _setStatus(SyncStatus value) {
    _status = value;
    if (!_statusController.isClosed) {
      _statusController.add(value);
    }
  }
}
