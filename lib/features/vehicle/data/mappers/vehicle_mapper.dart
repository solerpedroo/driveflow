import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../schema/vehicle_schema.dart';

/// Converte linhas Supabase ↔ [VehicleEntity].
abstract final class VehicleMapper {
  static VehicleEntity fromRow(Map<String, dynamic> row) {
    final fuelValue = row[VehicleSchema.fuel] as String? ?? FuelType.flex.value;
    return VehicleEntity(
      id: row[VehicleSchema.id] as String,
      userId: row[VehicleSchema.userId] as String,
      brand: row[VehicleSchema.brand] as String,
      model: row[VehicleSchema.model] as String,
      year: (row[VehicleSchema.year] as num).toInt(),
      plate: row[VehicleSchema.plate] as String?,
      fuel: FuelType.values.firstWhere(
        (f) => f.value == fuelValue,
        orElse: () => FuelType.flex,
      ),
      tankLiters: _toDouble(row[VehicleSchema.tank]),
      avgConsumptionKmPerLiter: _toDouble(row[VehicleSchema.avgConsumption]),
      odometerKm: _toDouble(row[VehicleSchema.odometer]) ?? 0,
      createdAt: _toDateTime(row[VehicleSchema.createdAt]),
      updatedAt: _toDateTime(row[VehicleSchema.updatedAt]),
    );
  }

  static Map<String, dynamic> toInsert({
    required String userId,
    required VehicleDraft draft,
  }) {
    return {
      VehicleSchema.userId: userId,
      VehicleSchema.brand: draft.brand.trim(),
      VehicleSchema.model: draft.model.trim(),
      VehicleSchema.year: draft.year,
      VehicleSchema.plate: _nullablePlate(draft.plate),
      VehicleSchema.fuel: draft.fuel.value,
      VehicleSchema.tank: draft.tankLiters,
      VehicleSchema.avgConsumption: draft.avgConsumptionKmPerLiter,
      VehicleSchema.odometer: draft.odometerKm,
    };
  }

  static Map<String, dynamic> toUpdate(VehicleDraft draft) {
    return {
      VehicleSchema.brand: draft.brand.trim(),
      VehicleSchema.model: draft.model.trim(),
      VehicleSchema.year: draft.year,
      VehicleSchema.plate: _nullablePlate(draft.plate),
      VehicleSchema.fuel: draft.fuel.value,
      VehicleSchema.tank: draft.tankLiters,
      VehicleSchema.avgConsumption: draft.avgConsumptionKmPerLiter,
      VehicleSchema.odometer: draft.odometerKm,
    };
  }

  static String? _nullablePlate(String? plate) {
    final trimmed = plate?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed.toUpperCase();
  }

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _toDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
