import '../../../../core/constants/ride_platforms.dart';
import '../entities/platform_connection_entity.dart';
import '../entities/platform_shift_recommendation.dart';

/// Resultado de uma sincronização com API de plataforma.
class PlatformSyncResult {
  const PlatformSyncResult({
    required this.platform,
    required this.importedCount,
    required this.skippedCount,
    required this.syncedAt,
    this.message,
  });

  final RidePlatform platform;
  final int importedCount;
  final int skippedCount;
  final DateTime syncedAt;
  final String? message;

  bool get hasImports => importedCount > 0;
}

/// Contrato de repositório para integrações Uber/99/InDrive.
abstract class PlatformIntegrationRepository {
  Stream<List<PlatformConnectionEntity>> watchConnections();

  Future<List<PlatformConnectionEntity>> fetchConnections();

  Future<PlatformConnectionEntity> connectPlatform(RidePlatform platform);

  Future<PlatformConnectionEntity> disconnectPlatform(RidePlatform platform);

  Future<PlatformSyncResult> syncPlatform(RidePlatform platform);

  Future<PlatformSyncResult> syncAllConnected();
}
