/// Vincula manutenções a despesas via descrição padronizada.
abstract final class MaintenanceExpenseLinker {
  static const tokenPrefix = 'maintenance:';

  static String description({
    required String maintenanceId,
    required String typeLabel,
    String? notes,
  }) {
    final detail = notes != null && notes.trim().isNotEmpty
        ? notes.trim()
        : typeLabel;
    return 'Manutenção — $detail · $tokenPrefix$maintenanceId';
  }

  static String tokenFor(String maintenanceId) => '$tokenPrefix$maintenanceId';

  static bool matches(String? description, String maintenanceId) {
    if (description == null) return false;
    return description.contains(tokenFor(maintenanceId));
  }
}
