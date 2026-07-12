/// Escapa um campo para CSV (RFC 4180).
String escapeCsvField(String value) {
  if (value.contains(',') ||
      value.contains('"') ||
      value.contains('\n') ||
      value.contains('\r')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

/// Junta campos escapados numa linha CSV.
String csvRow(List<String> fields) => fields.map(escapeCsvField).join(',');
