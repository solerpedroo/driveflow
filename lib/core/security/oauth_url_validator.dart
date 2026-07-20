/// Valida URLs de autorização OAuth antes de abrir no navegador.
abstract final class OAuthUrlValidator {
  static bool isSafeAuthorizationUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    if (uri.scheme != 'https') return false;
    if (uri.userInfo.isNotEmpty) return false;

    final host = uri.host.toLowerCase();
    if (host == 'localhost' || host.endsWith('.local')) return false;

    final path = uri.path.toLowerCase();
    return path.contains('oauth') || path.contains('authorize');
  }
}
