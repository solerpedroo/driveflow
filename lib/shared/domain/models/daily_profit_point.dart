/// Ponto diário para gráfico semanal de lucro.
class DailyProfitPoint {
  const DailyProfitPoint({
    required this.date,
    required this.profit,
    required this.weekdayLabel,
  });

  final DateTime date;
  final double profit;
  final String weekdayLabel;
}
