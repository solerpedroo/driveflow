import '../../../../core/constants/ride_platforms.dart';
import 'platform_trip_status.dart';

/// Corrida individual sincronizada de Uber, 99 ou InDrive.
class PlatformTripEntity {
  const PlatformTripEntity({
    required this.id,
    required this.userId,
    required this.platform,
    required this.externalId,
    required this.fareAmount,
    required this.tipAmount,
    required this.platformFee,
    required this.driverPayout,
    required this.startedAt,
    required this.status,
    this.distanceKm,
    this.durationMinutes,
    this.endedAt,
    this.pickupLabel,
    this.dropoffLabel,
    this.vehicleId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final RidePlatform platform;
  final String externalId;
  final double fareAmount;
  final double tipAmount;
  final double platformFee;
  final double driverPayout;
  final double? distanceKm;
  final int? durationMinutes;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? pickupLabel;
  final String? dropoffLabel;
  final PlatformTripStatus status;
  final String? vehicleId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  double get grossAmount => fareAmount + tipAmount;

  double get takeRatePercent =>
      grossAmount > 0 ? (platformFee / grossAmount) * 100 : 0;

  double get workedHours =>
      durationMinutes != null ? durationMinutes! / 60.0 : 0;

  bool get isCompleted => status == PlatformTripStatus.completed;
}
