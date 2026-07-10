import '../../../../core/constants/ride_platforms.dart';
import '../../domain/entities/platform_trip_entity.dart';
import '../../domain/entities/platform_trip_status.dart';
import '../schema/platform_trips_schema.dart';

abstract final class PlatformTripMapper {
  static PlatformTripEntity fromRow(Map<String, dynamic> row) {
    return PlatformTripEntity(
      id: row[PlatformTripsSchema.id] as String,
      userId: row[PlatformTripsSchema.userId] as String,
      platform: RidePlatform.fromValue(
        row[PlatformTripsSchema.platform] as String? ?? 'other',
      ),
      externalId: row[PlatformTripsSchema.externalId] as String,
      fareAmount: _toDouble(row[PlatformTripsSchema.fareAmount]) ?? 0,
      tipAmount: _toDouble(row[PlatformTripsSchema.tipAmount]) ?? 0,
      platformFee: _toDouble(row[PlatformTripsSchema.platformFee]) ?? 0,
      driverPayout: _toDouble(row[PlatformTripsSchema.driverPayout]) ?? 0,
      distanceKm: _toDouble(row[PlatformTripsSchema.distanceKm]),
      durationMinutes:
          (row[PlatformTripsSchema.durationMinutes] as num?)?.toInt(),
      startedAt:
          _toDateTime(row[PlatformTripsSchema.startedAt]) ?? DateTime.now(),
      endedAt: _toDateTime(row[PlatformTripsSchema.endedAt]),
      pickupLabel: row[PlatformTripsSchema.pickupLabel] as String?,
      dropoffLabel: row[PlatformTripsSchema.dropoffLabel] as String?,
      status: PlatformTripStatus.fromValue(
        row[PlatformTripsSchema.status] as String?,
      ),
      vehicleId: row[PlatformTripsSchema.vehicleId] as String?,
      createdAt: _toDateTime(row[PlatformTripsSchema.createdAt]),
      updatedAt: _toDateTime(row[PlatformTripsSchema.updatedAt]),
    );
  }

  static Map<String, dynamic> toInsert({
    required String userId,
    required PlatformTripEntity trip,
  }) {
    return {
      PlatformTripsSchema.userId: userId,
      PlatformTripsSchema.platform: trip.platform.value,
      PlatformTripsSchema.externalId: trip.externalId,
      PlatformTripsSchema.fareAmount: trip.fareAmount,
      PlatformTripsSchema.tipAmount: trip.tipAmount,
      PlatformTripsSchema.platformFee: trip.platformFee,
      PlatformTripsSchema.driverPayout: trip.driverPayout,
      if (trip.distanceKm != null)
        PlatformTripsSchema.distanceKm: trip.distanceKm,
      if (trip.durationMinutes != null)
        PlatformTripsSchema.durationMinutes: trip.durationMinutes,
      PlatformTripsSchema.startedAt: trip.startedAt.toUtc().toIso8601String(),
      if (trip.endedAt != null)
        PlatformTripsSchema.endedAt: trip.endedAt!.toUtc().toIso8601String(),
      if (trip.pickupLabel != null)
        PlatformTripsSchema.pickupLabel: trip.pickupLabel,
      if (trip.dropoffLabel != null)
        PlatformTripsSchema.dropoffLabel: trip.dropoffLabel,
      PlatformTripsSchema.status: trip.status.value,
      if (trip.vehicleId != null) PlatformTripsSchema.vehicleId: trip.vehicleId,
    };
  }

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _toDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();
    return DateTime.tryParse(value.toString())?.toLocal();
  }
}
