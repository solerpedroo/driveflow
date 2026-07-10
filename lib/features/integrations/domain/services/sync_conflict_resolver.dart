/// Regras de conflito entre dados manuais e sincronizados via API.
abstract final class SyncConflictResolver {
  /// Ganhos manuais nunca são sobrescritos por sync.
  static bool shouldPreserveManual({required String? source}) {
    return source == null || source == 'manual';
  }

  /// Ganhos importados de extrato podem ser atualizados por API se external_id bater.
  static bool allowApiOverwrite({required String? source}) {
    return source == 'api_sync' || source == 'import';
  }

  /// Prioridade de merge: manual > api_sync > import.
  static int sourcePriority(String? source) {
    switch (source) {
      case 'manual':
        return 3;
      case 'api_sync':
        return 2;
      case 'import':
        return 1;
      default:
        return 0;
    }
  }
}
