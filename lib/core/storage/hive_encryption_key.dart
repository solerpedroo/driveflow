import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

/// Gerencia a chave AES-256 para criptografia das boxes Hive.
abstract final class HiveEncryptionKey {
  static const _storageKey = 'driveflow_hive_aes_key_v1';

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  );

  /// Chave fixa para testes unitários (nunca usar em produção).
  static List<int>? testKeyOverride;

  static Future<List<int>> loadOrCreate() async {
    if (testKeyOverride != null) return testKeyOverride!;

    final stored = await _secureStorage.read(key: _storageKey);
    if (stored != null && stored.isNotEmpty) {
      return base64Decode(stored);
    }

    final key = Hive.generateSecureKey();
    await _secureStorage.write(key: _storageKey, value: base64Encode(key));
    return key;
  }

  static Future<void> clearStoredKey() => _secureStorage.delete(key: _storageKey);

  static HiveAesCipher cipherFromKey(List<int> key) =>
      HiveAesCipher(Uint8List.fromList(key));
}
