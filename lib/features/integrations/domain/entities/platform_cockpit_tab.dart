/// Abas do cockpit multi-app (Uber / 99 / InDrive).
enum PlatformCockpitTab {
  today('Hoje'),
  shift('Turno'),
  compare('Comparativo');

  const PlatformCockpitTab(this.label);

  final String label;

  static PlatformCockpitTab fromQuery(String? value) {
    if (value == null || value.isEmpty) return today;

    switch (value.toLowerCase()) {
      case 'today':
      case 'hoje':
        return today;
      case 'shift':
      case 'turno':
        return shift;
      case 'compare':
      case 'comparativo':
        return compare;
      default:
        return today;
    }
  }

  String get queryParam {
    switch (this) {
      case today:
        return 'today';
      case shift:
        return 'shift';
      case compare:
        return 'compare';
    }
  }
}
