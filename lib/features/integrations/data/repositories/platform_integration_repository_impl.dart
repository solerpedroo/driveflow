import '../../../../core/constants/ride_platforms.dart';
import '../../domain/entities/integration_status.dart';
import '../../domain/entities/platform_connection_entity.dart';
import '../../domain/entities/platform_oauth_session.dart';
import '../../domain/repositories/platform_integration_repository.dart';
import '../datasources/platform_connections_remote_datasource.dart';
import '../datasources/platform_oauth_remote_datasource.dart';
import '../datasources/platform_sync_remote_datasource.dart';
import '../../domain/services/platform_oauth_service.dart';
import '../mappers/platform_connection_mapper.dart';

class PlatformIntegrationRepositoryImpl implements PlatformIntegrationRepository {
  PlatformIntegrationRepositoryImpl({
    PlatformConnectionsRemoteDataSource? connectionsDataSource,
    PlatformSyncRemoteDataSource? syncDataSource,
    PlatformOAuthRemoteDataSource? oauthDataSource,
  })  : _connections =
            connectionsDataSource ?? PlatformConnectionsRemoteDataSource(),
        _sync = syncDataSource ?? PlatformSyncRemoteDataSource(),
        _oauth = oauthDataSource ?? PlatformOAuthRemoteDataSource();

  final PlatformConnectionsRemoteDataSource _connections;
  final PlatformSyncRemoteDataSource _sync;
  final PlatformOAuthRemoteDataSource _oauth;

  @override
  Stream<List<PlatformConnectionEntity>> watchConnections() {
    return _connections.watchConnections().map(
          (rows) => rows.map(PlatformConnectionMapper.fromRow).toList(),
        );
  }

  @override
  Future<List<PlatformConnectionEntity>> fetchConnections() async {
    final rows = await _connections.fetchConnections();
    return rows.map(PlatformConnectionMapper.fromRow).toList();
  }

  @override
  Future<PlatformOAuthSession> startOAuth(RidePlatform platform) {
    return _oauth.startOAuth(
      platform: platform,
      redirectUri: PlatformOAuthService.redirectUri(),
    );
  }

  @override
  Future<PlatformConnectionEntity> connectPlatform(
    RidePlatform platform,
  ) async {
    final row = await _connections.upsertConnection(
      platform: platform,
      status: IntegrationStatus.pending,
      lastSyncError: null,
    );
    return PlatformConnectionMapper.fromRow(row);
  }

  @override
  Future<PlatformConnectionEntity> disconnectPlatform(
    RidePlatform platform,
  ) async {
    final row = await _connections.disconnectConnection(platform: platform);
    return PlatformConnectionMapper.fromRow(row);
  }

  @override
  Future<PlatformSyncResult> syncPlatform(RidePlatform platform) async {
    try {
      final data = await _sync.syncPlatform(platform: platform);
      final tripsImported = (data['trips_imported'] as num?)?.toInt() ??
          (data['imported_count'] as num?)?.toInt() ??
          0;
      final earningsImported =
          (data['earnings_imported'] as num?)?.toInt() ?? 0;
      final skipped = (data['skipped_count'] as num?)?.toInt() ?? 0;
      final syncedAt = DateTime.tryParse(data['synced_at'] as String? ?? '') ??
          DateTime.now();

      await _connections.updateConnection(
        platform: platform,
        status: IntegrationStatus.connected,
        lastSyncedAt: syncedAt,
        lastSyncError: null,
      );

      return PlatformSyncResult(
        platform: platform,
        importedCount: tripsImported + earningsImported,
        skippedCount: skipped,
        syncedAt: syncedAt,
        tripsImported: tripsImported,
        earningsImported: earningsImported,
        message: data['message'] as String?,
      );
    } catch (e) {
      final errorMessage = e.toString();
      try {
        await _connections.updateConnection(
          platform: platform,
          status: IntegrationStatus.error,
          lastSyncError: errorMessage,
        );
      } catch (_) {
        // Mantém erro original se falhar ao persistir status.
      }
      rethrow;
    }
  }

  @override
  Future<PlatformSyncResult> syncAllConnected() async {
    final connections = await fetchConnections();
    final syncable = connections
        .where((c) => c.status.canSync)
        .map((c) => c.platform)
        .toList();

    if (syncable.isEmpty) {
      return PlatformSyncResult(
        platform: RidePlatform.uber,
        importedCount: 0,
        skippedCount: 0,
        syncedAt: DateTime.now(),
        message: 'Nenhuma plataforma conectada para atualizar.',
      );
    }

    var totalImported = 0;
    var totalSkipped = 0;
    var totalTrips = 0;
    var totalEarnings = 0;
    RidePlatform? lastPlatform;
    String? lastMessage;
    final syncedAt = DateTime.now();

    for (final platform in syncable) {
      final result = await syncPlatform(platform);
      totalImported += result.importedCount;
      totalSkipped += result.skippedCount;
      totalTrips += result.tripsImported;
      totalEarnings += result.earningsImported;
      lastPlatform = platform;
      lastMessage = result.message;
    }

    return PlatformSyncResult(
      platform: lastPlatform ?? RidePlatform.uber,
      importedCount: totalImported,
      skippedCount: totalSkipped,
      syncedAt: syncedAt,
      tripsImported: totalTrips,
      earningsImported: totalEarnings,
      message: lastMessage,
    );
  }
}
