/// Janela de ganho por dia da semana e hora.
class EarningTimeSlot {
  const EarningTimeSlot({
    required this.weekday,
    required this.hour,
    required this.totalProfit,
    required this.totalHours,
    required this.earningCount,
  });

  /// 1 = segunda … 7 = domingo (DateTime.weekday).
  final int weekday;
  final int hour;
  final double totalProfit;
  final double totalHours;
  final int earningCount;

  double get profitPerHour =>
      totalHours > 0 ? totalProfit / totalHours : 0;

  String get weekdayLabel {
    const labels = [
      '',
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];
    return labels[weekday];
  }

  String get hourLabel => '${hour.toString().padLeft(2, '0')}h';
}
