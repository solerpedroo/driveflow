import 'user_entity.dart';

/// Resultado do cadastro por e-mail — sessão imediata ou confirmação pendente.
sealed class SignUpResult {
  const SignUpResult();
}

final class SignUpCompleted extends SignUpResult {
  const SignUpCompleted(this.user);

  final UserEntity user;
}

final class SignUpAwaitingEmailConfirmation extends SignUpResult {
  const SignUpAwaitingEmailConfirmation({required this.email});

  final String email;
}
