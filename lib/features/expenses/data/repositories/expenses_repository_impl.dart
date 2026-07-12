import 'dart:async';
import 'dart:io';

import '../../../../core/errors/failure.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/sync_worker.dart';
import '../../../../core/storage/cached_remote_watch.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../../../../core/storage/local_entity_cache.dart';
import '../../../../core/storage/pending_sync_operation.dart';
import '../../../../core/storage/pending_sync_queue.dart';
import '../../../../core/utils/local_id_generator.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../datasources/expenses_remote_datasource.dart';
import '../mappers/expenses_mapper.dart';
import '../schema/expenses_schema.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  ExpensesRepositoryImpl({
    ExpensesRemoteDataSource? remote,
    LocalEntityCache? cache,
    PendingSyncQueue? syncQueue,
    ConnectivityService? connectivity,
    SyncWorker? syncWorker,
  })  : _remote = remote ?? ExpensesRemoteDataSource(),
        _cache = cache ?? LocalEntityCache(),
        _syncQueue = syncQueue ?? PendingSyncQueue(),
        _connectivity = connectivity ?? ConnectivityService(),
        _syncWorker = syncWorker;

  final ExpensesRemoteDataSource _remote;
  final LocalEntityCache _cache;
  final PendingSyncQueue _syncQueue;
  final ConnectivityService _connectivity;
  final SyncWorker? _syncWorker;

  @override
  Stream<List<ExpenseEntity>> watchExpenses() {
    return watchCachedRemote(
      remote: _remote.watchExpenses(),
      loadLocal: _loadLocal,
      mapRows: (rows) =>
          rows.map(ExpensesMapper.fromRow).toList(growable: false),
      persistRemote: (rows) => _cache.replaceAll(HiveBoxes.expenses, rows),
    );
  }

  @override
  Future<List<ExpenseEntity>> fetchExpenses() async {
    if (await _connectivity.isOnline) {
      try {
        final rows = await _remote.fetchExpenses();
        final entities =
            rows.map(ExpensesMapper.fromRow).toList(growable: false);
        await _cache.replaceAll(HiveBoxes.expenses, rows);
        return entities;
      } on Object {
        if (await _connectivity.isOnline) rethrow;
      }
    }
    return _loadLocal();
  }

  Future<String?> uploadReceipt(File file) async {
    if (!await _connectivity.isOnline) {
      throw const ServerFailure(
        message: 'Envio de comprovante requer conexão com a internet.',
      );
    }
    return _remote.uploadReceipt(file);
  }

  @override
  Future<ExpenseEntity> createExpense(ExpenseDraft draft) async {
    if (await _connectivity.isOnline) {
      try {
        final row = await _remote.createExpense(draft: draft);
        final entity = ExpensesMapper.fromRow(row);
        await _cache.upsert(HiveBoxes.expenses, ExpensesMapper.toRow(entity));
        return entity;
      } on Object {
        if (await _connectivity.isOnline) rethrow;
      }
    }
    if (draft.receiptUrl != null) {
      throw const ServerFailure(
        message: 'Comprovante pendente — conecte-se para enviar.',
      );
    }
    return _createOffline(draft);
  }

  @override
  Future<ExpenseEntity> updateExpense({
    required String id,
    required ExpenseDraft draft,
  }) async {
    if (await _connectivity.isOnline) {
      try {
        final row = await _remote.updateExpense(id: id, draft: draft);
        final entity = ExpensesMapper.fromRow(row);
        await _cache.upsert(HiveBoxes.expenses, ExpensesMapper.toRow(entity));
        return entity;
      } on Object {
        if (await _connectivity.isOnline) rethrow;
      }
    }
    return _updateOffline(id: id, draft: draft);
  }

  @override
  Future<void> deleteExpense(String id) async {
    if (await _connectivity.isOnline) {
      try {
        await _remote.deleteExpense(id);
        await _cache.remove(HiveBoxes.expenses, id);
        return;
      } on Object {
        if (await _connectivity.isOnline) rethrow;
      }
    }
    await _deleteOffline(id);
  }

  Future<List<ExpenseEntity>> _loadLocal() async {
    final rows = await _cache.readAll(HiveBoxes.expenses);
    final items = rows.map(ExpensesMapper.fromRow).toList(growable: true);
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  Future<ExpenseEntity> _createOffline(ExpenseDraft draft) async {
    final userId = _remote.currentUserId;
    if (userId == null) {
      throw const AuthFailure(message: 'Sessão expirada. Entre novamente.');
    }

    final id = LocalIdGenerator.create();
    final now = DateTime.now();
    final row = {
      ...ExpensesMapper.toInsert(userId: userId, draft: draft),
      ExpensesSchema.id: id,
      ExpensesSchema.createdAt: now.toUtc().toIso8601String(),
    };

    await _cache.upsert(HiveBoxes.expenses, row);
    await _enqueue(
      entityId: id,
      action: SyncAction.create,
      payload: ExpensesMapper.draftToJson(draft),
    );

    return ExpensesMapper.fromRow(row);
  }

  Future<ExpenseEntity> _updateOffline({
    required String id,
    required ExpenseDraft draft,
  }) async {
    final rows = await _cache.readAll(HiveBoxes.expenses);
    Map<String, dynamic>? existing;
    for (final row in rows) {
      if (row[ExpensesSchema.id] == id) {
        existing = row;
        break;
      }
    }
    if (existing == null) {
      throw const ServerFailure(
        message: 'Despesa não encontrada. Tente novamente.',
      );
    }

    final updated = {
      ...existing,
      ...ExpensesMapper.toUpdate(draft),
      ExpensesSchema.updatedAt: DateTime.now().toUtc().toIso8601String(),
    };
    await _cache.upsert(HiveBoxes.expenses, updated);

    if (LocalIdGenerator.isLocal(id)) {
      await _syncQueue.updatePayloadForEntity(
        entityId: id,
        payload: ExpensesMapper.draftToJson(draft),
      );
    } else {
      await _enqueue(
        entityId: id,
        action: SyncAction.update,
        payload: ExpensesMapper.draftToJson(draft),
      );
    }

    return ExpensesMapper.fromRow(updated);
  }

  Future<void> _deleteOffline(String id) async {
    await _cache.remove(HiveBoxes.expenses, id);

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
        entity: HiveBoxes.expenses,
        action: action,
        entityId: entityId,
        payload: payload,
        createdAt: DateTime.now(),
      ),
    );
    unawaited(_syncWorker?.processQueue());
  }
}
