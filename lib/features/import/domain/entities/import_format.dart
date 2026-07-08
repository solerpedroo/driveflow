/// Formato detectado do extrato bancário.
enum ImportFormat {
  nubank('Nubank'),
  inter('Inter'),
  generic('Genérico'),
  ofx('OFX');

  const ImportFormat(this.label);

  final String label;
}

/// Tipo de lançamento no extrato.
enum StatementEntryType {
  credit('Crédito'),
  debit('Débito');

  const StatementEntryType(this.label);

  final String label;
}
