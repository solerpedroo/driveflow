import '../../../../core/constants/app_constants.dart';

/// Entidade de veículo — domínio imutável.
class VehicleEntity {
  const VehicleEntity({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.year,
    this.plate,
    required this.fuel,
    this.tankLiters,
    this.avgConsumptionKmPerLiter,
    required this.odometerKm,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String brand;
  final String model;
  final int year;
  final String? plate;
  final FuelType fuel;
  final double? tankLiters;
  final double? avgConsumptionKmPerLiter;
  final double odometerKm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayName => '$brand $model';

  String get fuelLabel => fuel.label;

  VehicleEntity copyWith({
    String? id,
    String? userId,
    String? brand,
    String? model,
    int? year,
    String? plate,
    FuelType? fuel,
    double? tankLiters,
    double? avgConsumptionKmPerLiter,
    double? odometerKm,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      plate: plate ?? this.plate,
      fuel: fuel ?? this.fuel,
      tankLiters: tankLiters ?? this.tankLiters,
      avgConsumptionKmPerLiter:
          avgConsumptionKmPerLiter ?? this.avgConsumptionKmPerLiter,
      odometerKm: odometerKm ?? this.odometerKm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleEntity &&
          id == other.id &&
          userId == other.userId &&
          brand == other.brand &&
          model == other.model &&
          year == other.year &&
          plate == other.plate &&
          fuel == other.fuel &&
          tankLiters == other.tankLiters &&
          avgConsumptionKmPerLiter == other.avgConsumptionKmPerLiter &&
          odometerKm == other.odometerKm;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        brand,
        model,
        year,
        plate,
        fuel,
        tankLiters,
        avgConsumptionKmPerLiter,
        odometerKm,
      );
}

/// Dados para criar ou atualizar veículo.
class VehicleDraft {
  const VehicleDraft({
    required this.brand,
    required this.model,
    required this.year,
    this.plate,
    required this.fuel,
    this.tankLiters,
    this.avgConsumptionKmPerLiter,
    required this.odometerKm,
  });

  final String brand;
  final String model;
  final int year;
  final String? plate;
  final FuelType fuel;
  final double? tankLiters;
  final double? avgConsumptionKmPerLiter;
  final double odometerKm;
}
