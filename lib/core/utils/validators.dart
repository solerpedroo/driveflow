import 'currency_formatter.dart';

/// Validadores reutilizáveis em formulários.
abstract final class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe seu e-mail';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Informe sua senha';
    }
    if (value.length < minLength) {
      return 'Mínimo de $minLength caracteres';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
        !RegExp(r'[0-9]').hasMatch(value)) {
      return 'Use letras e números na senha';
    }
    return null;
  }

  static String? requiredField(String? value, {String fieldName = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName obrigatório';
    }
    return null;
  }

  static String? positiveNumber(String? value, {String fieldName = 'Valor'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName obrigatório';
    }
    final parsed = double.tryParse(
      value.replaceAll('.', '').replaceAll(',', '.'),
    );
    if (parsed == null || parsed <= 0) {
      return '$fieldName inválido';
    }
    return null;
  }

  static String? brlAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Valor obrigatório';
    }
    final parsed = CurrencyFormatter.tryParse(value);
    if (parsed == null || parsed <= 0) {
      return 'Valor inválido';
    }
    return null;
  }

  static String? odometer(String? value, {double? previous}) {
    final base = positiveNumber(value, fieldName: 'Odômetro');
    if (base != null) return base;
    if (previous != null) {
      final parsed = double.parse(
        value!.replaceAll('.', '').replaceAll(',', '.'),
      );
      if (parsed < previous) {
        return 'Odômetro menor que o último registro';
      }
    }
    return null;
  }
}
