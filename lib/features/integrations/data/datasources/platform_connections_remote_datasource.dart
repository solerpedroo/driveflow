import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/integration_status.dart';
import '../mappers/platform_connection_mapper.dart';
import '../schema/platform_connections_schema.dart';

class PlatformConnectionsRemoteDataSource {
  PlatformConnectionsRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  Stream<List<Map<String, dynamic>>> watchConnections() {
    final userId = _userId;
    if (userId == null) return Stream.value(const []);

    return _client
        .from(PlatformConnectionsSchema.table)
        .stream(primaryKey: [PlatformConnectionsSchema.id])
        .eq(PlatformConnectionsSchema.userId, userId);
  }

  Future<List<Map<String, dynamic>>> fetchConnections() async {
    final userId = _userId;
    if (userId == null) return const [];

    final rows = await _client
        .from(PlatformConnectionsSchema.table)
        .select()
        .eq(PlatformConnectionsSchema.userId, userId);

    return List<Map<String, dynamic>>.from(rows);
  }

  Future<Map<String, dynamic>> upsertConnection({
    required RidePlatform platform,
    required IntegrationStatus status,
    String? externalAccountId,
    String? lastSyncError,
    DateTime? lastSyncedAt,
  }) async {
    final userId = _userId;
    if (userId == null) {
      throw const AuthFailure(message: 'Sessão expirada. Entre novamente.');
    }

    try {
      return await _client
          .from(PlatformConnectionsSchema.table)
          .upsert(
            PlatformConnectionMapper.toUpsert(
              userId: userId,
              platform: platform,
              status: status,
              externalAccountId: externalAccountId,
              lastSyncError: lastSyncError,
              lastSyncedAt: lastSyncedAt,
            ),
            onConflict: '${PlatformConnectionsSchema.userId},${PlatformConnectionsSchema.platform}',
          )
          .select()
          .single();
    } on PostgrestException catch (e) {
      throw ServerFailure(message: e.message, cause: e);
    }
  }

  Future<Map<String, dynamic>> updateConnection({
    required RidePlatform platform,
    required IntegrationStatus status,
    String? lastSyncError,
    DateTime? lastSyncedAt,
    String? externalAccountId,
  }) async {
    final userId = _userId;
    if (userId == null) {
      throw const AuthFailure(message: 'Sessão expirada. Entre novamente.');
    }

    try {
      return await _client
          .from(PlatformConnectionsSchema.table)
          .update(
            PlatformConnectionMapper.toStatusUpdate(
              status: status,
              lastSyncError: lastSyncError,
              lastSyncedAt: lastSyncedAt,
              externalAccountId: externalAccountId,
            ),
          )
          .eq(PlatformConnectionsSchema.userId, userId)
          .eq(PlatformConnectionsSchema.platform, platform.value)
          .select()
          .single();
    } on PostgrestException catch (e) {
      throw ServerFailure(message: e.message, cause: e);
    }
  }
}
