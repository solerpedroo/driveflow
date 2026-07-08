/// Resumo financeiro consolidado de um período.
class PeriodSummary {
  const PeriodSummary({
    required this.revenue,
    required this.expenses,
    required this.profit,
    required this.workedHours,
    required this.rides,
    required this.kmDriven,
    required this.fuelExpense,
    required this.profitPerHour,
    required this.profitPerKm,
    required this.avgCostPerKm,
  });

  final double revenue;
  final double expenses;
  final double profit;
  final double workedHours;
  final int rides;
  final double kmDriven;
  final double fuelExpense;
  final double? profitPerHour;
  final double? profitPerKm;
  final double? avgCostPerKm;

  static const empty = PeriodSummary(
    revenue: 0,
    expenses: 0,
    profit: 0,
    workedHours: 0,
    rides: 0,
    kmDriven: 0,
    fuelExpense: 0,
    profitPerHour: null,
    profitPerKm: null,
    avgCostPerKm: null,
  );
}
