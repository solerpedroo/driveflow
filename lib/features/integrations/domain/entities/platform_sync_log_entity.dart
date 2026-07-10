import '../../../../core/constants/ride_platforms.dart';

/// Registro auditável de uma sincronização.
class PlatformSyncLogEntity {
  const PlatformSyncLogEntity({
    required this.id,
    required this.userId,
    required this.platform,
    required this.triggerSource,
    required this.tripsImported,
    required this.earningsImported,
    required this.skippedCount,
    required this.status,
    this.message,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final RidePlatform platform;
  final String triggerSource;
  final int tripsImported;
  final int earningsImported;
  final int skippedCount;
  final String status;
  final String? message;
  final DateTime createdAt;

  bool get isSuccess => status == 'success';
}
