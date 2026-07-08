import '../utils/date_utils.dart';

/// Períodos de filtro usados em ganhos e despesas.
enum DateRangePeriod {
  today('Hoje'),
  week('Semana'),
  month('Mês');

  const DateRangePeriod(this.label);

  final String label;
}

/// Intervalo de datas inclusivo para filtros.
class DateRange {
  const DateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  bool contains(DateTime date) =>
      !date.isBefore(start) && !date.isAfter(end);
}

/// Resolve [DateRange] a partir de um [DateRangePeriod].
DateRange dateRangeForPeriod(DateRangePeriod period, [DateTime? anchor]) {
  final now = anchor ?? DateTime.now();
  switch (period) {
    case DateRangePeriod.today:
      return DateRange(
        start: DateUtilsDriveFlow.startOfDay(now),
        end: DateUtilsDriveFlow.endOfDay(now),
      );
    case DateRangePeriod.week:
      return DateRange(
        start: DateUtilsDriveFlow.startOfWeek(now),
        end: DateUtilsDriveFlow.endOfWeek(now),
      );
    case DateRangePeriod.month:
      return DateRange(
        start: DateUtilsDriveFlow.startOfMonth(now),
        end: DateUtilsDriveFlow.endOfMonth(now),
      );
  }
}
