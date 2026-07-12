import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/platform_sync_logs_remote_datasource.dart';
import '../../data/mappers/platform_sync_log_mapper.dart';
import '../../domain/entities/platform_sync_log_entity.dart';

final platformSyncLogsRemoteProvider =
    Provider((ref) => PlatformSyncLogsRemoteDataSource());

final platformSyncLogsStreamProvider =
    StreamProvider.autoDispose<List<PlatformSyncLogEntity>>((ref) {
  return ref.watch(platformSyncLogsRemoteProvider).watchLogs().map(
        (rows) => rows.map(PlatformSyncLogMapper.fromRow).toList(),
      );
});

final platformSyncLogsProvider =
    Provider<AsyncValue<List<PlatformSyncLogEntity>>>((ref) {
  return ref.watch(platformSyncLogsStreamProvider);
});
