import 'dart:async';

import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/sync_worker.dart';
import '../../../../core/storage/cached_remote_watch.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../../../../core/storage/local_entity_cache.dart';
import '../../../../core/storage/pending_sync_operation.dart';
import '../../../../core/storage/pending_sync_queue.dart';
import '../../../../core/utils/local_id_generator.dart';
import '../../domain/entities/shift_history_entry.dart';
import '../../domain/entities/shift_session_entity.dart';
import '../../domain/repositories/shift_history_repository.dart';
import '../../domain/services/shift_history_archiver.dart';
import '../datasources/shift_sessions_remote_datasource.dart';
import '../mappers/shift_sessions_mapper.dart';

class ShiftHistoryRepositoryImpl implements ShiftHistoryRepository {
  ShiftHistoryRepositoryImpl({
    ShiftSessionsRemoteDataSource? remote,
    LocalEntityCache? cache,
    PendingSyncQueue? syncQueue,
    ConnectivityService? connectivity,
    SyncWorker? syncWorker,
  })  : _remote = remote ?? ShiftSessionsRemoteDataSource(),
        _cache = cache ?? LocalEntityCache(),
        _syncQueue = syncQueue ?? PendingSyncQueue(),
        _connectivity = connectivity ?? ConnectivityService(),
        _syncWorker = syncWorker;

  final ShiftSessionsRemoteDataSource _remote;
  final LocalEntityCache _cache;
  final PendingSyncQueue _syncQueue;
  final ConnectivityService _connectivity;
  final SyncWorker? _syncWorker;

  @override
  Stream<List<ShiftHistoryEntry>> watchHistory() {
    return watchCachedRemote(
      remote: _remote.watchHistory(),
      loadLocal: _loadLocal,
      mapRows: (rows) =>
          rows.map(ShiftSessionsMapper.fromRow).toList(growable: false),
      persistRemote: (rows) => _cache.replaceAll(HiveBoxes.shiftHistory, rows),
    );
  }

  @override
  Future<List<ShiftHistoryEntry>> fetchHistory() async {
    if (await _connectivity.isOnline) {
      try {
        final rows = await _remote.fetchHistory();
        final entries =
            rows.map(ShiftSessionsMapper.fromRow).toList(growable: false);
        await _cache.replaceAll(HiveBoxes.shiftHistory, rows);
        return entries;
      } on Object {
        if (await _connectivity.isOnline) rethrow;
      }
    }
    return _loadLocal();
  }

  @override
  Future<ShiftHistoryEntry?> readById(String id) async {
    final local = await _loadLocal();
    for (final entry in local) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  @override
  Future<ShiftHistoryEntry> archiveCompleted({
    required ShiftSessionEntity session,
    required String userId,
    required double revenue,
    required int rides,
    required double? revenuePerHour,
    required double adherenceScore,
    required int matchedPlanBlocks,
    required int totalPlanBlocks,
    required Map<RidePlatform, double> revenueByPlatform,
    List<ShiftBlockOutcome> blockOutcomes = const [],
  }) async {
    final entry = ShiftHistoryArchiver.build(
      session: session,
      userId: userId,
      revenue: revenue,
      rides: rides,
      revenuePerHour: revenuePerHour,
      adherenceScore: adherenceScore,
      matchedPlanBlocks: matchedPlanBlocks,
      totalPlanBlocks: totalPlanBlocks,
      revenueByPlatform: revenueByPlatform,
      blockOutcomes: blockOutcomes,
    );

    if (await _connectivity.isOnline) {
      try {
        final row = await _remote.createCompleted(entry: entry);
        final saved = ShiftSessionsMapper.fromRow(row);
        await _cache.upsert(HiveBoxes.shiftHistory, ShiftSessionsMapper.toRow(saved));
        DriveFlowAnalytics.logEvent('shift_completed');
        return saved;
      } on Object {
        if (await _connectivity.isOnline) rethrow;
      }
    }

    return _archiveOffline(entry);
  }

  Future<ShiftHistoryEntry> _archiveOffline(ShiftHistoryEntry entry) async {
    final localId = LocalIdGenerator.create();
    final offline = ShiftHistoryEntry(
      id: localId,
      userId: entry.userId,
      startedAt: entry.startedAt,
      endedAt: entry.endedAt,
      elapsed: entry.elapsed,
      accumulatedPause: entry.accumulatedPause,
      vehicleId: entry.vehicleId,
      isTaxiMode: entry.isTaxiMode,
      revenue: entry.revenue,
      rides: entry.rides,
      revenuePerHour: entry.revenuePerHour,
      adherenceScore: entry.adherenceScore,
      matchedPlanBlocks: entry.matchedPlanBlocks,
      totalPlanBlocks: entry.totalPlanBlocks,
      planBlocks: entry.planBlocks,
      revenueByPlatform: entry.revenueByPlatform,
      blockOutcomes: entry.blockOutcomes,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );

    await _cache.upsert(
      HiveBoxes.shiftHistory,
      ShiftSessionsMapper.toRow(offline),
    );
    await _syncQueue.enqueue(
      PendingSyncOperation(
        id: 'shift_${offline.id}',
        entity: HiveBoxes.shiftHistory,
        action: SyncAction.create,
        entityId: offline.id,
        payload: ShiftSessionsMapper.toRow(offline),
        createdAt: DateTime.now(),
      ),
    );
    unawaited(_syncWorker?.processQueue());
    DriveFlowAnalytics.logEvent('shift_completed');
    return offline;
  }

  Future<List<ShiftHistoryEntry>> _loadLocal() async {
    final rows = await _cache.readAll(HiveBoxes.shiftHistory);
    return rows.map(ShiftSessionsMapper.fromRow).toList(growable: false);
  }
}
