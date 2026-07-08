import 'package:intl/intl.dart';

/// Utilitários de data/hora para motoristas (turnos, metas, relatórios).
abstract final class DateUtilsDriveFlow {
  static final DateFormat dayMonth = DateFormat('dd/MM', 'pt_BR');
  static final DateFormat dayMonthYear = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final DateFormat weekdayShort = DateFormat('EEE', 'pt_BR');
  static final DateFormat timeHm = DateFormat('HH:mm', 'pt_BR');
  static final DateFormat dateTime = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return startOfDay(date.subtract(Duration(days: weekday - 1)));
  }

  static DateTime endOfWeek(DateTime date) {
    final start = startOfWeek(date);
    return endOfDay(start.add(const Duration(days: 6)));
  }

  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month);

  static DateTime endOfMonth(DateTime date) =>
      endOfDay(DateTime(date.year, date.month + 1, 0));

  static DateTime startOfYear(DateTime date) => DateTime(date.year);

  static DateTime endOfYear(DateTime date) =>
      endOfDay(DateTime(date.year, 12, 31));

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());
}
