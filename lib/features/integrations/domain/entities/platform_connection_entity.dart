import '../../../../core/constants/ride_platforms.dart';
import 'integration_status.dart';

/// Conexão do motorista com Uber, 99 ou InDrive.
class PlatformConnectionEntity {
  const PlatformConnectionEntity({
    required this.id,
    required this.userId,
    required this.platform,
    required this.status,
    this.externalAccountId,
    this.lastSyncedAt,
    this.lastSyncError,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final RidePlatform platform;
  final IntegrationStatus status;
  final String? externalAccountId;
  final DateTime? lastSyncedAt;
  final String? lastSyncError;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isConnected => status.isActive;

  PlatformConnectionEntity copyWith({
    String? id,
    String? userId,
    RidePlatform? platform,
    IntegrationStatus? status,
    String? externalAccountId,
    DateTime? lastSyncedAt,
    String? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlatformConnectionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      platform: platform ?? this.platform,
      status: status ?? this.status,
      externalAccountId: externalAccountId ?? this.externalAccountId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastSyncError: lastSyncError ?? this.lastSyncError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
