import 'package:intl/intl.dart';

/// Formatação monetária BRL consistente em todo o app.
abstract final class CurrencyFormatter {
  static final NumberFormat _brl = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
    decimalDigits: 2,
  );

  static final NumberFormat _compact = NumberFormat.compactCurrency(
    locale: 'pt_BR',
    symbol: r'R$',
    decimalDigits: 0,
  );

  static String format(num value) => _brl.format(value);

  static String formatCompact(num value) => _compact.format(value);

  static String formatSigned(num value) {
    final prefix = value >= 0 ? '+' : '';
    return '$prefix${format(value)}';
  }

  /// Parse "R$ 1.234,56" ou "1234,56" para double.
  static double? tryParse(String input) {
    final cleaned = input
        .replaceAll(r'R$', '')
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .replaceAll('\u00a0', '')
        .trim()
        .replaceAll(',', '.');
    return double.tryParse(cleaned);
  }
}
