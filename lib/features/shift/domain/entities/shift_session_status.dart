/// Estado operacional de uma sessão de turno.
enum ShiftSessionStatus {
  active('active'),
  paused('paused'),
  completed('completed');

  const ShiftSessionStatus(this.value);

  final String value;

  static ShiftSessionStatus fromValue(String? raw) {
    return ShiftSessionStatus.values.firstWhere(
      (status) => status.value == raw,
      orElse: () => ShiftSessionStatus.active,
    );
  }

  bool get isActiveLike => this == active || this == paused;
}
