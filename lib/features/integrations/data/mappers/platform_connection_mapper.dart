import '../../../../core/constants/ride_platforms.dart';
import '../../domain/entities/integration_status.dart';
import '../../domain/entities/platform_connection_entity.dart';
import '../schema/platform_connections_schema.dart';

abstract final class PlatformConnectionMapper {
  static PlatformConnectionEntity fromRow(Map<String, dynamic> row) {
    return PlatformConnectionEntity(
      id: row[PlatformConnectionsSchema.id] as String,
      userId: row[PlatformConnectionsSchema.userId] as String,
      platform: RidePlatform.fromValue(
        row[PlatformConnectionsSchema.platform] as String? ?? 'other',
      ),
      status: IntegrationStatus.fromValue(
        row[PlatformConnectionsSchema.status] as String?,
      ),
      externalAccountId:
          row[PlatformConnectionsSchema.externalAccountId] as String?,
      lastSyncedAt: _toDateTime(row[PlatformConnectionsSchema.lastSyncedAt]),
      lastSyncError: row[PlatformConnectionsSchema.lastSyncError] as String?,
      createdAt: _toDateTime(row[PlatformConnectionsSchema.createdAt]),
      updatedAt: _toDateTime(row[PlatformConnectionsSchema.updatedAt]),
    );
  }

  static Map<String, dynamic> toUpsert({
    required String userId,
    required RidePlatform platform,
    required IntegrationStatus status,
    String? externalAccountId,
    String? lastSyncError,
    DateTime? lastSyncedAt,
  }) {
    return {
      PlatformConnectionsSchema.userId: userId,
      PlatformConnectionsSchema.platform: platform.value,
      PlatformConnectionsSchema.status: status.value,
      if (externalAccountId != null)
        PlatformConnectionsSchema.externalAccountId: externalAccountId,
      if (lastSyncError != null)
        PlatformConnectionsSchema.lastSyncError: lastSyncError,
      if (lastSyncedAt != null)
        PlatformConnectionsSchema.lastSyncedAt:
            lastSyncedAt.toUtc().toIso8601String(),
    };
  }

  static Map<String, dynamic> toStatusUpdate({
    required IntegrationStatus status,
    String? lastSyncError,
    DateTime? lastSyncedAt,
    String? externalAccountId,
  }) {
    return {
      PlatformConnectionsSchema.status: status.value,
      PlatformConnectionsSchema.lastSyncError: lastSyncError,
      if (lastSyncedAt != null)
        PlatformConnectionsSchema.lastSyncedAt:
            lastSyncedAt.toUtc().toIso8601String(),
      if (externalAccountId != null)
        PlatformConnectionsSchema.externalAccountId: externalAccountId,
    };
  }

  static DateTime? _toDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();
    return DateTime.tryParse(value.toString())?.toLocal();
  }
}
