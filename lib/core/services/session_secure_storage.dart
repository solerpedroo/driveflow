import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Backup seguro do refresh token Supabase.
class SessionSecureStorage {
  SessionSecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const _refreshTokenKey = 'driveflow_supabase_refresh_token';

  final FlutterSecureStorage _storage;

  Future<void> saveRefreshToken(String? token) async {
    if (token == null || token.isEmpty) return;
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> readRefreshToken() =>
      _storage.read(key: _refreshTokenKey);

  Future<void> clear() => _storage.delete(key: _refreshTokenKey);
}
