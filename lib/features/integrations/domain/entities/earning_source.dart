/// Origem de um registro de ganho.
enum EarningSource {
  manual('manual', 'Manual'),
  import_('import', 'Importação'),
  apiSync('api_sync', 'Automático');

  const EarningSource(this.value, this.label);

  final String value;
  final String label;

  static EarningSource fromValue(String? value) {
    return EarningSource.values.firstWhere(
      (s) => s.value == value,
      orElse: () => EarningSource.manual,
    );
  }
}
