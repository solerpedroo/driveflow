import '../constants/date_range_period.dart';

/// Filtros reutilizáveis para transações financeiras.
abstract final class TransactionFilters {
  static List<T> byDateRange<T>(
    List<T> items,
    DateRange range,
    DateTime Function(T item) readDate,
  ) {
    return items
        .where((item) => range.contains(readDate(item)))
        .toList(growable: false);
  }

  static double sumAmounts<T>(
    Iterable<T> items,
    double Function(T item) readAmount,
  ) {
    return items.fold<double>(0, (sum, item) => sum + readAmount(item));
  }
}
