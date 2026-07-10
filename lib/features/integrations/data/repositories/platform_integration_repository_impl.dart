import '../../../../core/constants/ride_platforms.dart';
import '../../domain/entities/integration_status.dart';
import '../../domain/entities/platform_connection_entity.dart';
import '../../domain/repositories/platform_integration_repository.dart';
import '../datasources/platform_connections_remote_datasource.dart';
import '../datasources/platform_sync_remote_datasource.dart';
import '../mappers/platform_connection_mapper.dart';

class PlatformIntegrationRepositoryImpl implements PlatformIntegrationRepository {
  PlatformIntegrationRepositoryImpl({
    PlatformConnectionsRemoteDataSource? connectionsDataSource,
    PlatformSyncRemoteDataSource? syncDataSource,
  })  : _connections =
            connectionsDataSource ?? PlatformConnectionsRemoteDataSource(),
        _sync = syncDataSource ?? PlatformSyncRemoteDataSource();

  final PlatformConnectionsRemoteDataSource _connections;
  final PlatformSyncRemoteDataSource _sync;

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
    final row = await _connections.upsertConnection(
      platform: platform,
      status: IntegrationStatus.disconnected,
      lastSyncError: null,
    );
    return PlatformConnectionMapper.fromRow(row);
  }

  @override
  Future<PlatformSyncResult> syncPlatform(RidePlatform platform) async {
    final data = await _sync.syncPlatform(platform: platform);
    final imported = (data['imported_count'] as num?)?.toInt() ?? 0;
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
      importedCount: imported,
      skippedCount: skipped,
      syncedAt: syncedAt,
      message: data['message'] as String?,
    );
  }

  @override
  Future<PlatformSyncResult> syncAllConnected() async {
    final connections = await fetchConnections();
    final connected = connections
        .where((c) => c.status.canSync)
        .map((c) => c.platform)
        .toList();

    var totalImported = 0;
    var totalSkipped = 0;
    RidePlatform? lastPlatform;
    String? lastMessage;
    final syncedAt = DateTime.now();

    for (final platform in connected) {
      final result = await syncPlatform(platform);
      totalImported += result.importedCount;
      totalSkipped += result.skippedCount;
      lastPlatform = platform;
      lastMessage = result.message;
    }

    return PlatformSyncResult(
      platform: lastPlatform ?? RidePlatform.uber,
      importedCount: totalImported,
      skippedCount: totalSkipped,
      syncedAt: syncedAt,
      message: lastMessage,
    );
  }
}
