import 'dart:async';

import '../../../../core/errors/failure.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/sync_worker.dart';
import '../../../../core/storage/cached_remote_watch.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../../../../core/storage/local_entity_cache.dart';
import '../../../../core/storage/pending_sync_operation.dart';
import '../../../../core/storage/pending_sync_queue.dart';
import '../../../../core/utils/local_id_generator.dart';
import '../../domain/entities/earning_entity.dart';
import '../../domain/repositories/earnings_repository.dart';
import '../datasources/earnings_remote_datasource.dart';
import '../mappers/earnings_mapper.dart';
import '../schema/earnings_schema.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  EarningsRepositoryImpl({
    EarningsRemoteDataSource? remote,
    LocalEntityCache? cache,
    PendingSyncQueue? syncQueue,
    ConnectivityService? connectivity,
    SyncWorker? syncWorker,
  })  : _remote = remote ?? EarningsRemoteDataSource(),
        _cache = cache ?? LocalEntityCache(),
        _syncQueue = syncQueue ?? PendingSyncQueue(),
        _connectivity = connectivity ?? ConnectivityService(),
        _syncWorker = syncWorker;

  final EarningsRemoteDataSource _remote;
  final LocalEntityCache _cache;
  final PendingSyncQueue _syncQueue;
  final ConnectivityService _connectivity;
  final SyncWorker? _syncWorker;

  @override
  Stream<List<EarningEntity>> watchEarnings() {
    return watchCachedRemote(
      remote: _remote.watchEarnings(),
      loadLocal: _loadLocal,
      mapRows: (rows) =>
          rows.map(EarningsMapper.fromRow).toList(growable: false),
      persistRemote: (rows) => _cache.replaceAll(HiveBoxes.earnings, rows),
    );
  }

  @override
  Future<List<EarningEntity>> fetchEarnings() async {
    if (await _connectivity.isOnline) {
      try {
        final rows = await _remote.fetchEarnings();
        final entities =
            rows.map(EarningsMapper.fromRow).toList(growable: false);
        await _cache.replaceAll(HiveBoxes.earnings, rows);
        return entities;
      } on Object {
        if (await _connectivity.isOnline) rethrow;
      }
    }
    return _loadLocal();
  }

  @override
  Future<EarningEntity> createEarning(EarningDraft draft) async {
    if (await _connectivity.isOnline) {
      try {
        final row = await _remote.createEarning(draft: draft);
        final entity = EarningsMapper.fromRow(row);
        await _cache.upsert(HiveBoxes.earnings, EarningsMapper.toRow(entity));
        DriveFlowAnalytics.logEvent('earning_added');
        return entity;
      } on Object {
        if (await _connectivity.isOnline) rethrow;
      }
    }
    return _createOffline(draft);
  }

  @override
  Future<EarningEntity> updateEarning({
    required String id,
    required EarningDraft draft,
  }) async {
    if (await _connectivity.isOnline) {
      try {
        final row = await _remote.updateEarning(id: id, draft: draft);
        final entity = EarningsMapper.fromRow(row);
        await _cache.upsert(HiveBoxes.earnings, EarningsMapper.toRow(entity));
        return entity;
      } on Object {
        if (await _connectivity.isOnline) rethrow;
      }
    }
    return _updateOffline(id: id, draft: draft);
  }

  @override
  Future<void> deleteEarning(String id) async {
    if (await _connectivity.isOnline) {
      try {
        await _remote.deleteEarning(id);
        await _cache.remove(HiveBoxes.earnings, id);
        return;
      } on Object {
        if (await _connectivity.isOnline) rethrow;
      }
    }
    await _deleteOffline(id);
  }

  Future<List<EarningEntity>> _loadLocal() async {
    final rows = await _cache.readAll(HiveBoxes.earnings);
    final items = rows.map(EarningsMapper.fromRow).toList(growable: true);
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  Future<EarningEntity> _createOffline(EarningDraft draft) async {
    final userId = _remote.currentUserId;
    if (userId == null) {
      throw const AuthFailure(message: 'Sessão expirada. Entre novamente.');
    }

    final id = LocalIdGenerator.create();
    final now = DateTime.now();
    final row = {
      ...EarningsMapper.toInsert(userId: userId, draft: draft),
      EarningsSchema.id: id,
      EarningsSchema.createdAt: now.toUtc().toIso8601String(),
    };

    await _cache.upsert(HiveBoxes.earnings, row);
    await _enqueue(
      entityId: id,
      action: SyncAction.create,
      payload: EarningsMapper.draftToJson(draft),
    );

    return EarningsMapper.fromRow(row);
  }

  Future<EarningEntity> _updateOffline({
    required String id,
    required EarningDraft draft,
  }) async {
    final rows = await _cache.readAll(HiveBoxes.earnings);
    Map<String, dynamic>? existing;
    for (final row in rows) {
      if (row[EarningsSchema.id] == id) {
        existing = row;
        break;
      }
    }
    if (existing == null) {
      throw const ServerFailure(message: 'Ganho não encontrado. Tente novamente.');
    }

    final updated = {
      ...existing,
      ...EarningsMapper.toUpdate(draft),
      EarningsSchema.updatedAt: DateTime.now().toUtc().toIso8601String(),
    };
    await _cache.upsert(HiveBoxes.earnings, updated);

    if (LocalIdGenerator.isLocal(id)) {
      await _syncQueue.updatePayloadForEntity(
        entityId: id,
        payload: EarningsMapper.draftToJson(draft),
      );
    } else {
      await _enqueue(
        entityId: id,
        action: SyncAction.update,
        payload: EarningsMapper.draftToJson(draft),
      );
    }

    return EarningsMapper.fromRow(updated);
  }

  Future<void> _deleteOffline(String id) async {
    await _cache.remove(HiveBoxes.earnings, id);

    if (LocalIdGenerator.isLocal(id)) {
      await _syncQueue.removeByEntityId(id);
      return;
    }

    await _enqueue(
      entityId: id,
      action: SyncAction.delete,
      payload: const {},
    );
  }

  Future<void> _enqueue({
    required String entityId,
    required SyncAction action,
    required Map<String, dynamic> payload,
  }) async {
    await _syncQueue.enqueue(
      PendingSyncOperation(
        id: _syncQueue.generateOperationId(),
        entity: HiveBoxes.earnings,
        action: action,
        entityId: entityId,
        payload: payload,
        createdAt: DateTime.now(),
      ),
    );
    unawaited(_syncWorker?.processQueue());
  }
}
