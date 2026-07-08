/// Resposta da previsão assistida por IA.
class AiForecastMessage {
  const AiForecastMessage({
    required this.id,
    required this.summary,
    required this.forecast7Days,
    required this.forecast30Days,
    required this.optimistic30Days,
    required this.pessimistic30Days,
    required this.createdAt,
  });

  final String id;
  final String summary;
  final double forecast7Days;
  final double forecast30Days;
  final double optimistic30Days;
  final double pessimistic30Days;
  final DateTime createdAt;
}
