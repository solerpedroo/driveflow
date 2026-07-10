import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/platform_sync_log_entity.dart';
import '../mappers/platform_sync_log_mapper.dart';
import '../schema/platform_sync_logs_schema.dart';

class PlatformSyncLogsRemoteDataSource {
  PlatformSyncLogsRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  Stream<List<Map<String, dynamic>>> watchLogs({int limit = 30}) {
    final userId = _userId;
    if (userId == null) return Stream.value(const []);

    return _client
        .from(PlatformSyncLogsSchema.table)
        .stream(primaryKey: [PlatformSyncLogsSchema.id])
        .eq(PlatformSyncLogsSchema.userId, userId)
        .order(PlatformSyncLogsSchema.createdAt, ascending: false)
        .limit(limit);
  }

  Future<List<PlatformSyncLogEntity>> fetchLogs({int limit = 30}) async {
    final userId = _userId;
    if (userId == null) return const [];

    final rows = await _client
        .from(PlatformSyncLogsSchema.table)
        .select()
        .eq(PlatformSyncLogsSchema.userId, userId)
        .order(PlatformSyncLogsSchema.createdAt, ascending: false)
        .limit(limit);

    return rows
        .map((row) => PlatformSyncLogMapper.fromRow(row as Map<String, dynamic>))
        .toList();
  }
}
