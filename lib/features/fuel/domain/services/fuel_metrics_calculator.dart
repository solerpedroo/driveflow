import '../entities/fuel_log_entity.dart';

/// Fórmulas de km/L, custo/km e média rolling.
abstract final class FuelMetricsCalculator {
  static const defaultRollingWindow = 5;

  static FuelMetrics compute({
    required double odometerKm,
    required double liters,
    required double totalAmount,
    double? previousOdometerKm,
  }) {
    if (previousOdometerKm == null || liters <= 0) {
      return const FuelMetrics();
    }

    final deltaKm = odometerKm - previousOdometerKm;
    if (deltaKm <= 0 || totalAmount <= 0) {
      return const FuelMetrics();
    }

    return FuelMetrics(
      kmPerLiter: deltaKm / liters,
      costPerKm: totalAmount / deltaKm,
    );
  }

  /// Odômetro do abastecimento anterior imediato (menor que o atual).
  static double? previousOdometer({
    required double currentOdometerKm,
    required Iterable<FuelLogEntity> existingLogs,
    String? excludeLogId,
  }) {
    final candidates = existingLogs
        .where((log) => log.id != excludeLogId)
        .where((log) => log.odometerKm < currentOdometerKm)
        .map((log) => log.odometerKm)
        .toList(growable: false);

    if (candidates.isEmpty) return null;
    candidates.sort();
    return candidates.last;
  }

  static double? rollingAverageKmPerLiter(
    List<FuelLogEntity> logs, {
    int window = defaultRollingWindow,
  }) {
    final values = logs
        .map((log) => log.kmPerLiter)
        .whereType<double>()
        .where((v) => v > 0)
        .take(window)
        .toList(growable: false);

    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }
}
