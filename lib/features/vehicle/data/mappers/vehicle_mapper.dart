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
      nickname: row[VehicleSchema.nickname] as String?,
      plate: row[VehicleSchema.plate] as String?,
      fuel: FuelType.values.firstWhere(
        (f) => f.value == fuelValue,
        orElse: () => FuelType.flex,
      ),
      tankLiters: _toDouble(row[VehicleSchema.tank]),
      avgConsumptionKmPerLiter: _toDouble(row[VehicleSchema.avgConsumption]),
      odometerKm: _toDouble(row[VehicleSchema.odometer]) ?? 0,
      isDefault: row[VehicleSchema.isDefault] as bool? ?? false,
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
      VehicleSchema.nickname: _nullableText(draft.nickname),
      VehicleSchema.plate: _nullablePlate(draft.plate),
      VehicleSchema.fuel: draft.fuel.value,
      VehicleSchema.tank: draft.tankLiters,
      VehicleSchema.avgConsumption: draft.avgConsumptionKmPerLiter,
      VehicleSchema.odometer: draft.odometerKm,
      VehicleSchema.isDefault: draft.isDefault,
    };
  }

  static Map<String, dynamic> toUpdate(VehicleDraft draft) {
    return {
      VehicleSchema.brand: draft.brand.trim(),
      VehicleSchema.model: draft.model.trim(),
      VehicleSchema.year: draft.year,
      VehicleSchema.nickname: _nullableText(draft.nickname),
      VehicleSchema.plate: _nullablePlate(draft.plate),
      VehicleSchema.fuel: draft.fuel.value,
      VehicleSchema.tank: draft.tankLiters,
      VehicleSchema.avgConsumption: draft.avgConsumptionKmPerLiter,
      VehicleSchema.odometer: draft.odometerKm,
      VehicleSchema.isDefault: draft.isDefault,
    };
  }

  static Map<String, dynamic> toRow(VehicleEntity entity) {
    return {
      VehicleSchema.id: entity.id,
      VehicleSchema.userId: entity.userId,
      VehicleSchema.brand: entity.brand,
      VehicleSchema.model: entity.model,
      VehicleSchema.year: entity.year,
      VehicleSchema.nickname: entity.nickname,
      VehicleSchema.plate: entity.plate,
      VehicleSchema.fuel: entity.fuel.value,
      VehicleSchema.tank: entity.tankLiters,
      VehicleSchema.avgConsumption: entity.avgConsumptionKmPerLiter,
      VehicleSchema.odometer: entity.odometerKm,
      VehicleSchema.isDefault: entity.isDefault,
      if (entity.createdAt != null)
        VehicleSchema.createdAt: entity.createdAt!.toUtc().toIso8601String(),
      if (entity.updatedAt != null)
        VehicleSchema.updatedAt: entity.updatedAt!.toUtc().toIso8601String(),
    };
  }

  static Map<String, dynamic> draftToJson(VehicleDraft draft) {
    return {
      'brand': draft.brand,
      'model': draft.model,
      'year': draft.year,
      'nickname': draft.nickname,
      'plate': draft.plate,
      'fuel': draft.fuel.value,
      'tank_liters': draft.tankLiters,
      'avg_consumption_km_per_liter': draft.avgConsumptionKmPerLiter,
      'odometer_km': draft.odometerKm,
      'is_default': draft.isDefault,
    };
  }

  static VehicleDraft draftFromJson(Map<String, dynamic> json) {
    return VehicleDraft(
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      nickname: json['nickname'] as String?,
      plate: json['plate'] as String?,
      fuel: FuelType.values.firstWhere(
        (f) => f.value == (json['fuel'] as String? ?? FuelType.flex.value),
        orElse: () => FuelType.flex,
      ),
      tankLiters: _toDouble(json['tank_liters']),
      avgConsumptionKmPerLiter:
          _toDouble(json['avg_consumption_km_per_liter']),
      odometerKm: _toDouble(json['odometer_km']) ?? 0,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  static String? _nullableText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
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
