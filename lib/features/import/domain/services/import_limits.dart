/// Limites de segurança para importação de extratos.
abstract final class ImportLimits {
  static const maxBytes = 5 * 1024 * 1024;
  static const maxLines = 2000;
}
