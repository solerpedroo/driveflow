/// Status de uma corrida sincronizada da plataforma.
enum PlatformTripStatus {
  completed('completed', 'Concluída'),
  cancelled('cancelled', 'Cancelada'),
  adjusted('adjusted', 'Ajustada');

  const PlatformTripStatus(this.value, this.label);

  final String value;
  final String label;

  static PlatformTripStatus fromValue(String? value) {
    return PlatformTripStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => PlatformTripStatus.completed,
    );
  }
}
