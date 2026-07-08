import 'import_limits.dart';

/// Valida tamanho e quantidade de linhas antes do parse.
abstract final class ImportFileValidator {
  static void validate({
    required int byteLength,
    required int lineCount,
  }) {
    if (byteLength > ImportLimits.maxBytes) {
      throw FormatException(
        'Arquivo muito grande (máx. ${ImportLimits.maxBytes ~/ (1024 * 1024)} MB).',
      );
    }
    if (lineCount > ImportLimits.maxLines) {
      throw FormatException(
        'Arquivo com muitas linhas (máx. ${ImportLimits.maxLines}).',
      );
    }
    if (lineCount < 2) {
      throw const FormatException('Arquivo vazio ou sem dados.');
    }
  }
}
