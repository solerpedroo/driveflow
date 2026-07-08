import '../../../../core/constants/app_constants.dart';

/// Vincula abastecimentos a despesas via descrição padronizada.
abstract final class FuelExpenseLinker {
  static const tokenPrefix = 'fuel_log:';

  static String description({
    required String fuelLogId,
    required FuelType fuelType,
    String? station,
  }) {
    final place = station != null && station.trim().isNotEmpty
        ? station.trim()
        : fuelType.label;
    return 'Abastecimento — $place · $tokenPrefix$fuelLogId';
  }

  static String tokenFor(String fuelLogId) => '$tokenPrefix$fuelLogId';

  static bool matches(String? description, String fuelLogId) {
    if (description == null) return false;
    return description.contains(tokenFor(fuelLogId));
  }
}
