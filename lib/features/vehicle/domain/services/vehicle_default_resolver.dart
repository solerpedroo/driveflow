import '../entities/vehicle_entity.dart';

/// Resolve qual veículo está ativo na UI a partir da lista e preferência local.
abstract final class VehicleDefaultResolver {
  /// [preferredId] vem do Hive; null indica fallback para `isDefault` ou primeiro.
  static VehicleEntity? resolve({
    required List<VehicleEntity> vehicles,
    String? preferredId,
  }) {
    if (vehicles.isEmpty) return null;

    if (preferredId != null) {
      for (final vehicle in vehicles) {
        if (vehicle.id == preferredId) return vehicle;
      }
    }

    for (final vehicle in vehicles) {
      if (vehicle.isDefault) return vehicle;
    }

    return vehicles.first;
  }

  /// Próximo veículo a promover como padrão após exclusão do atual default.
  static VehicleEntity? nextDefaultAfterDelete({
    required List<VehicleEntity> vehicles,
    required String deletedId,
  }) {
    final remaining =
        vehicles.where((v) => v.id != deletedId).toList(growable: false);
    if (remaining.isEmpty) return null;
    return remaining.first;
  }
}
