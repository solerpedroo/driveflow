import 'package:supabase_flutter/supabase_flutter.dart';

/// Falhas de domínio/dados com mensagens amigáveis ao usuário.
sealed class Failure implements Exception {
  const Failure({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'Failure: $message';
}

final class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Sem conexão. Tente novamente.',
    super.cause,
  });
}

final class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.cause});

  static String messageForError(Object error) {
    if (error is AuthException) {
      final code = error.code?.toLowerCase() ?? '';
      final message = error.message.toLowerCase();
      if (code.contains('invalid_credentials') ||
          message.contains('invalid login credentials')) {
        return 'E-mail ou senha incorretos.';
      }
      if (code.contains('user_already_exists') ||
          message.contains('user already registered')) {
        return 'Este e-mail já está cadastrado.';
      }
      if (message.contains('email not confirmed')) {
        return 'Confirme seu e-mail antes de entrar.';
      }
      if (code.contains('weak_password') || message.contains('weak password')) {
        return 'Senha fraca. Use pelo menos 8 caracteres.';
      }
      if (code.contains('over_request_rate_limit') ||
          message.contains('too many requests')) {
        return 'Muitas tentativas. Aguarde um momento.';
      }
    }

    final text = error.toString().toLowerCase();
    if (text.contains('invalid login credentials')) {
      return 'E-mail ou senha incorretos.';
    }
    if (text.contains('user already registered')) {
      return 'Este e-mail já está cadastrado.';
    }
    if (text.contains('email not confirmed')) {
      return 'Confirme seu e-mail antes de entrar.';
    }
    if (text.contains('network') || text.contains('socket')) {
      return 'Sem conexão. Verifique sua internet.';
    }
    return 'Não foi possível autenticar. Tente novamente.';
  }
}

final class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Erro ao acessar dados locais.',
    super.cause,
  });
}

final class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Erro no servidor. Tente mais tarde.',
    super.cause,
  });
}

final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.cause});
}

final class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Algo deu errado.',
    super.cause,
  });
}

/// Exceção técnica não exposta diretamente na UI.
class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'AppException: $message';
}
