/// Resultado da previsão de lucro.
class ProfitForecastResult {
  const ProfitForecastResult({
    required this.forecast7Days,
    required this.forecast30Days,
    required this.optimistic30Days,
    required this.pessimistic30Days,
    required this.averageDailyProfit,
    required this.sampleDays,
  });

  final double forecast7Days;
  final double forecast30Days;
  final double optimistic30Days;
  final double pessimistic30Days;
  final double averageDailyProfit;
  final int sampleDays;
}
