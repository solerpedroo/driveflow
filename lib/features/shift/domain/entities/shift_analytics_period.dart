/// Janela de análise dos turnos encerrados.
enum ShiftAnalyticsPeriod {
  days7(7, '7 dias'),
  days30(30, '30 dias');

  const ShiftAnalyticsPeriod(this.days, this.label);

  final int days;
  final String label;
}
