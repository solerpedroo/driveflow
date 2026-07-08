import '../../../../core/constants/app_constants.dart';

/// Registro de abastecimento vinculado a um veículo.
class FuelLogEntity {
  const FuelLogEntity({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.fuelType,
    required this.pricePerLiter,
    required this.liters,
    required this.totalAmount,
    required this.odometerKm,
    this.station,
    this.kmPerLiter,
    this.costPerKm,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String vehicleId;
  final String userId;
  final FuelType fuelType;
  final double pricePerLiter;
  final double liters;
  final double totalAmount;
  final double odometerKm;
  final String? station;
  final double? kmPerLiter;
  final double? costPerKm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasMetrics => kmPerLiter != null && costPerKm != null;

  FuelLogEntity copyWith({
    String? id,
    String? vehicleId,
    String? userId,
    FuelType? fuelType,
    double? pricePerLiter,
    double? liters,
    double? totalAmount,
    double? odometerKm,
    String? station,
    double? kmPerLiter,
    double? costPerKm,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FuelLogEntity(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      fuelType: fuelType ?? this.fuelType,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      liters: liters ?? this.liters,
      totalAmount: totalAmount ?? this.totalAmount,
      odometerKm: odometerKm ?? this.odometerKm,
      station: station ?? this.station,
      kmPerLiter: kmPerLiter ?? this.kmPerLiter,
      costPerKm: costPerKm ?? this.costPerKm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Dados para criar ou atualizar abastecimento.
class FuelLogDraft {
  const FuelLogDraft({
    required this.vehicleId,
    required this.fuelType,
    required this.pricePerLiter,
    required this.liters,
    required this.totalAmount,
    required this.odometerKm,
    this.station,
    this.kmPerLiter,
    this.costPerKm,
  });

  final String vehicleId;
  final FuelType fuelType;
  final double pricePerLiter;
  final double liters;
  final double totalAmount;
  final double odometerKm;
  final String? station;
  final double? kmPerLiter;
  final double? costPerKm;
}

/// Resultado dos cálculos de consumo.
class FuelMetrics {
  const FuelMetrics({this.kmPerLiter, this.costPerKm});

  final double? kmPerLiter;
  final double? costPerKm;

  bool get isCalculable => kmPerLiter != null && costPerKm != null;
}
