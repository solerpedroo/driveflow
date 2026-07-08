import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/sync_worker.dart';
import '../../../../core/storage/active_vehicle_storage.dart';
import '../../../../core/storage/cached_remote_watch.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../../../../core/storage/local_entity_cache.dart';
import '../../../../core/storage/pending_sync_operation.dart';
import '../../../../core/storage/pending_sync_queue.dart';
import '../../../../core/utils/local_id_generator.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../domain/services/vehicle_default_resolver.dart';
import '../datasources/vehicle_remote_datasource.dart';
import '../datasources/vehicles_local_datasource.dart';
import '../mappers/vehicle_mapper.dart';
import '../schema/vehicle_schema.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  VehicleRepositoryImpl({
    VehicleRemoteDataSource? remote,
    VehiclesLocalDataSource? local,
    LocalEntityCache? cache,
    PendingSyncQueue? syncQueue,
    ConnectivityService? connectivity,
    SyncWorker? syncWorker,
  })  : _remote = remote ?? VehicleRemoteDataSource(),
        _local = local ?? VehiclesLocalDataSource(cache: cache),
        _cache = cache ?? LocalEntityCache(),
        _syncQueue = syncQueue ?? PendingSyncQueue(),
        _connectivity = connectivity ?? ConnectivityService(),
        _syncWorker = syncWorker;

  final VehicleRemoteDataSource _remote;
  final VehiclesLocalDataSource _local;
  final LocalEntityCache _cache;
  final PendingSyncQueue _syncQueue;
  final ConnectivityService _connectivity;
  final SyncWorker? _syncWorker;

  @override
  Stream<List<VehicleEntity>> watchVehicles() {
    return watchCachedRemote(
      remote: _remote.watchVehicles(),
      loadLocal: _loadLocal,
      mapRows: (rows) =>
          rows.map(VehicleMapper.fromRow).toList(growable: false),
      persistRemote: (rows) => _local.replaceAll(rows),
    );
  }

  @override
  Future<List<VehicleEntity>> fetchVehicles() async {
    if (await _connectivity.isOnline) {
      try {
        final rows = await _remote.fetchVehicles();
        final entities =
            rows.map(VehicleMapper.fromRow).toList(growable: false);
        await _local.replaceAll(rows);
        return entities;
      } on Object {
        if (await _connectivity.isOnline) rethrow;
      }
    }
    return _loadLocal();
  }

  @override
  Future<VehicleEntity> createVehicle(VehicleDraft draft) async {
    final existing = await fetchVehicles();
    final shouldBeDefault = existing.isEmpty || draft.isDefault;
    final normalizedDraft = VehicleDraft(
      brand: draft.brand,
      model: draft.model,
      year: draft.year,
      nickname: draft.nickname,
      plate: draft.plate,
      fuel: draft.fuel,
      tankLiters: draft.tankLiters,
      avgConsumptionKmPerLiter: draft.avgConsumptionKmPerLiter,
      odometerKm: draft.odometerKm,
      isDefault: shouldBeDefault,
    );

    if (await _connectivity.isOnline) {
      try {
        final row = await _remote.createVehicle(draft: normalizedDraft);
        final entity = VehicleMapper.fromRow(row);
        await _cache.upsert(HiveBoxes.vehicles, VehicleMapper.toRow(entity));
        if (shouldBeDefault || existing.isEmpty) {
          await setActiveVehicleId(entity.id);
        }
        return entity;
      } on Object {
        if (await _connectivity.isOnline) rethrow;
      }
    }
    return _createOffline(normalizedDraft);
  }

  @override
  Future<VehicleEntity> updateVehicle({
    required String id,
    required VehicleDraft draft,
  }) async {
    if (await _connectivity.isOnline) {
      try {
        final row = await _remote.updateVehicle(id: id, draft: draft);
        final entity = VehicleMapper.fromRow(row);
        await _cache.upsert(HiveBoxes.vehicles, VehicleMapper.toRow(entity));
        if (draft.isDefault) {
          await setActiveVehicleId(entity.id);
        }
        return entity;
      } on Object {
        if (await _connectivity.isOnline) rethrow;
      }
    }
    return _updateOffline(id: id, draft: draft);
  }

  @override
  Future<void> deleteVehicle(String id) async {
    final vehicles = await fetchVehicles();
    if (vehicles.length <= 1) {
      throw const ValidationFailure(
        message: 'Mantenha pelo menos um veículo cadastrado.',
      );
    }

    final deleted = vehicles.firstWhere((v) => v.id == id);
    final nextDefault = VehicleDefaultResolver.nextDefaultAfterDelete(
      vehicles: vehicles,
      deletedId: id,
    );

    if (await _connectivity.isOnline) {
      try {
        await _remote.deleteVehicle(id);
        await _local.remove(id);

        if (deleted.isDefault && nextDefault != null) {
          await _remote.setDefaultVehicle(nextDefault.id);
        }

        if (readActiveVehicleId() == id) {
          await setActiveVehicleId(nextDefault?.id);
        }
        return;
      } on Object {
        if (await _connectivity.isOnline) rethrow;
      }
    }

    await _deleteOffline(
      id: id,
      promoteDefaultId:
          deleted.isDefault ? nextDefault?.id : null,
    );
  }

  @override
  Future<void> setDefaultVehicle(String id) async {
    if (await _connectivity.isOnline) {
      await _remote.setDefaultVehicle(id);
      await setActiveVehicleId(id);
      return;
    }

    throw const NetworkFailure(
      message: 'Definir veículo padrão requer conexão.',
    );
  }

  @override
  Future<void> setActiveVehicleId(String? vehicleId) =>
      ActiveVehicleStorage.writeActiveVehicleId(vehicleId);

  @override
  String? readActiveVehicleId() => ActiveVehicleStorage.readActiveVehicleId();

  Future<List<VehicleEntity>> _loadLocal() async {
    final rows = await _local.readAll();
    return rows.map(VehicleMapper.fromRow).toList(growable: false);
  }

  Future<VehicleEntity> _createOffline(VehicleDraft draft) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthFailure(message: 'Sessão expirada. Entre novamente.');
    }

    final localId = LocalIdGenerator.create();
    final row = {
      VehicleSchema.id: localId,
      VehicleSchema.userId: userId,
      ...VehicleMapper.toInsert(userId: userId, draft: draft),
      VehicleSchema.createdAt: DateTime.now().toUtc().toIso8601String(),
      VehicleSchema.updatedAt: DateTime.now().toUtc().toIso8601String(),
    };

    await _cache.upsert(HiveBoxes.vehicles, row);
    await _syncQueue.enqueue(
      PendingSyncOperation(
        id: LocalIdGenerator.create(),
        entity: HiveBoxes.vehicles,
        action: SyncAction.create,
        entityId: localId,
        payload: VehicleMapper.draftToJson(draft),
        createdAt: DateTime.now(),
      ),
    );
    _syncWorker?.processQueue();

    final entity = VehicleMapper.fromRow(row);
    if (draft.isDefault) {
      await setActiveVehicleId(entity.id);
    }
    return entity;
  }

  Future<VehicleEntity> _updateOffline({
    required String id,
    required VehicleDraft draft,
  }) async {
    final rows = await _local.readAll();
    final current = rows.firstWhere(
      (row) => row[VehicleSchema.id] == id,
      orElse: () => throw const ValidationFailure(
        message: 'Veículo não encontrado.',
      ),
    );

    final updated = {
      ...current,
      ...VehicleMapper.toUpdate(draft),
      VehicleSchema.updatedAt: DateTime.now().toUtc().toIso8601String(),
    };
    await _cache.upsert(HiveBoxes.vehicles, updated);

    if (!LocalIdGenerator.isLocal(id)) {
      await _syncQueue.enqueue(
        PendingSyncOperation(
          id: LocalIdGenerator.create(),
          entity: HiveBoxes.vehicles,
          action: SyncAction.update,
          entityId: id,
          payload: VehicleMapper.draftToJson(draft),
          createdAt: DateTime.now(),
        ),
      );
      _syncWorker?.processQueue();
    }

    if (draft.isDefault) {
      await setActiveVehicleId(id);
    }

    return VehicleMapper.fromRow(updated);
  }

  Future<void> _deleteOffline({
    required String id,
    String? promoteDefaultId,
  }) async {
    await _local.remove(id);

    if (!LocalIdGenerator.isLocal(id)) {
      await _syncQueue.enqueue(
        PendingSyncOperation(
          id: LocalIdGenerator.create(),
          entity: HiveBoxes.vehicles,
          action: SyncAction.delete,
          entityId: id,
          payload: {
            if (promoteDefaultId != null) 'promote_default_id': promoteDefaultId,
          },
          createdAt: DateTime.now(),
        ),
      );
      _syncWorker?.processQueue();
    }

    if (readActiveVehicleId() == id) {
      await setActiveVehicleId(promoteDefaultId);
    }
  }
}
