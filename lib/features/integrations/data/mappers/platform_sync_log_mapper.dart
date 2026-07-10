import '../../../../core/constants/ride_platforms.dart';
import '../../domain/entities/platform_sync_log_entity.dart';
import '../schema/platform_sync_logs_schema.dart';

abstract final class PlatformSyncLogMapper {
  static PlatformSyncLogEntity fromRow(Map<String, dynamic> row) {
    return PlatformSyncLogEntity(
      id: row[PlatformSyncLogsSchema.id] as String,
      userId: row[PlatformSyncLogsSchema.userId] as String,
      platform: RidePlatform.fromValue(
        row[PlatformSyncLogsSchema.platform] as String? ?? 'other',
      ),
      triggerSource: row[PlatformSyncLogsSchema.triggerSource] as String? ?? 'manual',
      tripsImported:
          (row[PlatformSyncLogsSchema.tripsImported] as num?)?.toInt() ?? 0,
      earningsImported:
          (row[PlatformSyncLogsSchema.earningsImported] as num?)?.toInt() ?? 0,
      skippedCount:
          (row[PlatformSyncLogsSchema.skippedCount] as num?)?.toInt() ?? 0,
      status: row[PlatformSyncLogsSchema.status] as String? ?? 'success',
      message: row[PlatformSyncLogsSchema.message] as String?,
      createdAt: _toDateTime(row[PlatformSyncLogsSchema.createdAt]) ??
          DateTime.now(),
    );
  }

  static DateTime? _toDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();
    return DateTime.tryParse(value.toString())?.toLocal();
  }
}
