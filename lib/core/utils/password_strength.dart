/// Requisitos e pontuação de força de senha.
abstract final class PasswordStrength {
  static const int minLength = 8;

  static bool hasMinLength(String password) =>
      password.length >= minLength;

  static bool hasUppercase(String password) =>
      password.contains(RegExp(r'[A-ZÀ-Ý]'));

  static bool hasLowercase(String password) =>
      password.contains(RegExp(r'[a-zà-ý]'));

  static bool hasDigit(String password) =>
      password.contains(RegExp(r'[0-9]'));

  /// 0 = vazio, 1 = fraca, 2 = média, 3 = forte, 4 = muito forte.
  static int score(String password) {
    if (password.isEmpty) return 0;
    var met = 0;
    if (hasMinLength(password)) met++;
    if (hasUppercase(password)) met++;
    if (hasLowercase(password)) met++;
    if (hasDigit(password)) met++;
    return met;
  }

  static bool isStrong(String password) => score(password) >= 4;

  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe sua senha';
    }
    if (!hasMinLength(value)) {
      return 'Mínimo de $minLength caracteres';
    }
    if (!hasUppercase(value)) {
      return 'Inclua pelo menos uma letra maiúscula';
    }
    if (!hasLowercase(value)) {
      return 'Inclua pelo menos uma letra minúscula';
    }
    if (!hasDigit(value)) {
      return 'Inclua pelo menos um número';
    }
    return null;
  }
}
