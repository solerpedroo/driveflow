import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/network/supabase_certificate_pinning.dart';

/// URL e chave anon via `--dart-define-from-file=env.json`.
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://127.0.0.1:54321',
  );

  static const publishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const certSha256 = String.fromEnvironment(
    'SUPABASE_CERT_SHA256',
    defaultValue: '',
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  static bool get isLocalHost {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final host = uri.host.toLowerCase();
    return host == '127.0.0.1' ||
        host == 'localhost' ||
        host == '10.0.2.2';
  }

  static void assertProductionSafe() {
    if (kDebugMode) return;

    if (!isConfigured) {
      throw StateError(
        'SUPABASE_URL e SUPABASE_ANON_KEY são obrigatórios em release. '
        'Use --dart-define-from-file=env.json.',
      );
    }

    final uri = Uri.tryParse(url);
    if (uri != null && uri.scheme != 'https' && !isLocalHost) {
      throw StateError(
        'SUPABASE_URL deve usar HTTPS em produção (recebido: ${uri.scheme}).',
      );
    }
  }
}

/// Inicializa Supabase; em dev usa emulador local por padrão.
Future<void> initializeSupabase() async {
  SupabaseConfig.assertProductionSafe();
  SupabaseCertificatePinning.installIfConfigured();

  if (!SupabaseConfig.isConfigured && kDebugMode) {
    debugPrint(
      'DriveFlow: SUPABASE_ANON_KEY não definida. '
      'Use env.example.json como base para env.json.',
    );
  }

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.isConfigured
        ? SupabaseConfig.publishableKey
        : 'placeholder-anon-key-for-foundation',
    debug: kDebugMode,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
}

/// Resolução de host para emulador Supabase por plataforma.
abstract final class SupabaseDevSetup {
  static String resolveLocalHost() {
    if (kIsWeb) return '127.0.0.1';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return '10.0.2.2';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return '127.0.0.1';
      default:
        return '127.0.0.1';
    }
  }

  static String localUrl({int port = 54321}) =>
      'http://${resolveLocalHost()}:$port';
}

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
