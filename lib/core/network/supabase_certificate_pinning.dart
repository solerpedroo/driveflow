import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Pinning opcional do certificado TLS do Supabase (release).
///
/// Configure `SUPABASE_CERT_SHA256` via `--dart-define` com o fingerprint
/// SHA-256 (hex, lowercase) do certificado do projeto Supabase.
abstract final class SupabaseCertificatePinning {
  static const _expectedPin = String.fromEnvironment('SUPABASE_CERT_SHA256');

  static void installIfConfigured() {
    if (kIsWeb || _expectedPin.isEmpty) return;
    HttpOverrides.global = _PinnedHttpOverrides(_expectedPin);
  }
}

class _PinnedHttpOverrides extends HttpOverrides {
  _PinnedHttpOverrides(this.expectedPin);

  final String expectedPin;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(SecurityContext.defaultContext);
    client.badCertificateCallback = (cert, host, port) {
      final fingerprint = sha256.convert(cert.der).bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      return fingerprint == expectedPin;
    };
    return client;
  }
}
