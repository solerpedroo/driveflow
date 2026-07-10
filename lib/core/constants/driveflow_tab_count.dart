/// Número de abas do shell principal (MVP).
const kDriveFlowMainTabCount = 5;

/// Índices das abas do [DriveFlowMainShell].
abstract final class DriveFlowTab {
  static const dashboard = 0;
  static const earnings = 1;
  static const expenses = 2;
  static const reports = 3;
  static const profile = 4;

  /// Resolve índice da aba a partir do query param `?tab=`.
  static int fromQueryParam(String? value) {
    if (value == null || value.isEmpty) return dashboard;

    final parsed = int.tryParse(value);
    if (parsed != null) return _normalize(parsed);

    switch (value.toLowerCase()) {
      case 'dashboard':
        return dashboard;
      case 'earnings':
        return earnings;
      case 'expenses':
        return expenses;
      case 'reports':
        return reports;
      case 'profile':
        return profile;
      default:
        return dashboard;
    }
  }

  /// Nome do query param `?tab=` para o índice informado.
  static String queryParamFor(int tab) {
    switch (_normalize(tab)) {
      case dashboard:
        return 'dashboard';
      case earnings:
        return 'earnings';
      case expenses:
        return 'expenses';
      case reports:
        return 'reports';
      case profile:
        return 'profile';
      default:
        return 'dashboard';
    }
  }

  static int _normalize(int tab) {
    if (tab < dashboard || tab >= kDriveFlowMainTabCount) {
      return dashboard;
    }
    return tab;
  }
}
