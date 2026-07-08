import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}

/// Inicializa Supabase; em dev usa emulador local por padrão.
Future<void> initializeSupabase() async {
  if (!SupabaseConfig.isConfigured && kDebugMode) {
    debugPrint(
      'DriveFlow: SUPABASE_ANON_KEY não definida. '
      'Use env.example.json como base para env.json.',
    );
  }

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.publishableKey.isNotEmpty
        ? SupabaseConfig.publishableKey
        : 'placeholder-anon-key-for-foundation',
    debug: kDebugMode,
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
