/// Estado da conexão OAuth/API com uma plataforma de corridas.
enum IntegrationStatus {
  disconnected('disconnected', 'Desconectado'),
  pending('pending', 'Aguardando autorização'),
  connected('connected', 'Conectado'),
  error('error', 'Erro na sincronização'),
  tokenExpired('token_expired', 'Token expirado');

  const IntegrationStatus(this.value, this.label);

  final String value;
  final String label;

  bool get isActive => this == connected;

  bool get canSync =>
      this == connected || this == error || this == tokenExpired;

  static IntegrationStatus fromValue(String? value) {
    return IntegrationStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => IntegrationStatus.disconnected,
    );
  }
}
