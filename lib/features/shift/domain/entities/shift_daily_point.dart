/// Agregado diário de turnos para gráficos.
class ShiftDailyPoint {
  const ShiftDailyPoint({
    required this.date,
    required this.revenue,
    required this.shiftCount,
    required this.avgAdherence,
    required this.revenuePerHour,
  });

  final DateTime date;
  final double revenue;
  final int shiftCount;
  final double avgAdherence;
  final double revenuePerHour;

  String get weekdayLabel {
    const labels = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return labels[date.weekday % 7];
  }

  String get dayLabel => '${date.day.toString().padLeft(2, '0')}/${date.month}';
}
