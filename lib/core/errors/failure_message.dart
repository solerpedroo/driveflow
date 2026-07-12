import 'failure.dart';

/// Mensagens amigáveis para erros exibidos na UI.
abstract final class FailureMessage {
  static String forObject(Object? error) {
    if (error == null) return 'Algo deu errado.';
    if (error is Failure) return error.message;
    if (error is AppException) return error.message;

    final text = error.toString().toLowerCase();
    if (text.contains('network') ||
        text.contains('socket') ||
        text.contains('connection')) {
      return 'Sem conexão. Verifique sua internet.';
    }
    if (text.contains('timeout')) {
      return 'A operação demorou demais. Tente novamente.';
    }
    return 'Não foi possível concluir. Tente novamente.';
  }
}
