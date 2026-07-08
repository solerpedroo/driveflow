import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/fuel_log_entity.dart';
import '../schema/fuel_log_schema.dart';

abstract final class FuelLogMapper {
  static FuelLogEntity fromRow(Map<String, dynamic> row) {
    final fuelValue =
        row[FuelLogSchema.fuelType] as String? ?? FuelType.gasoline.value;
    return FuelLogEntity(
      id: row[FuelLogSchema.id] as String,
      vehicleId: row[FuelLogSchema.vehicleId] as String,
      userId: row[FuelLogSchema.userId] as String,
      station: row[FuelLogSchema.station] as String?,
      fuelType: FuelType.values.firstWhere(
        (f) => f.value == fuelValue,
        orElse: () => FuelType.gasoline,
      ),
      pricePerLiter: _toDouble(row[FuelLogSchema.pricePerLiter]) ?? 0,
      liters: _toDouble(row[FuelLogSchema.liters]) ?? 0,
      totalAmount: _toDouble(row[FuelLogSchema.totalAmount]) ?? 0,
      odometerKm: _toDouble(row[FuelLogSchema.odometer]) ?? 0,
      kmPerLiter: _toDouble(row[FuelLogSchema.kmPerLiter]),
      costPerKm: _toDouble(row[FuelLogSchema.costPerKm]),
      createdAt: _toDateTime(row[FuelLogSchema.createdAt]),
      updatedAt: _toDateTime(row[FuelLogSchema.updatedAt]),
    );
  }

  static Map<String, dynamic> toInsert({
    required String userId,
    required FuelLogDraft draft,
  }) {
    return {
      FuelLogSchema.vehicleId: draft.vehicleId,
      FuelLogSchema.userId: userId,
      FuelLogSchema.station: _nullableText(draft.station),
      FuelLogSchema.fuelType: draft.fuelType.value,
      FuelLogSchema.pricePerLiter: draft.pricePerLiter,
      FuelLogSchema.liters: draft.liters,
      FuelLogSchema.totalAmount: draft.totalAmount,
      FuelLogSchema.odometer: draft.odometerKm,
      FuelLogSchema.kmPerLiter: draft.kmPerLiter,
      FuelLogSchema.costPerKm: draft.costPerKm,
    };
  }

  static Map<String, dynamic> toUpdate(FuelLogDraft draft) {
    return {
      FuelLogSchema.station: _nullableText(draft.station),
      FuelLogSchema.fuelType: draft.fuelType.value,
      FuelLogSchema.pricePerLiter: draft.pricePerLiter,
      FuelLogSchema.liters: draft.liters,
      FuelLogSchema.totalAmount: draft.totalAmount,
      FuelLogSchema.odometer: draft.odometerKm,
      FuelLogSchema.kmPerLiter: draft.kmPerLiter,
      FuelLogSchema.costPerKm: draft.costPerKm,
    };
  }

  static String? _nullableText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
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
