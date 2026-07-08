/// Filtra transações por veículo ativo no escopo.
///
/// [vehicleId] null = todos os registros (inclui legado sem `vehicle_id`).
abstract final class VehicleScopeFilter {
  static List<T> byVehicle<T>({
    required List<T> items,
    required String? vehicleId,
    required String? Function(T item) vehicleIdOf,
  }) {
    if (vehicleId == null) return items;
    return items
        .where((item) => vehicleIdOf(item) == vehicleId)
        .toList(growable: false);
  }
}
