import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/services/platform_oauth_deep_link_listener.dart';
import 'core/presentation/providers/sync_providers.dart';
import 'core/services/crash_reporting.dart';
import 'core/services/session_secure_storage.dart';
import 'core/storage/hive_storage.dart';
import 'core/services/maintenance_notification_service.dart';
import 'core/theme/theme_mode_provider.dart';
import 'supabase_dev_setup.dart';

Future<void> main() async {
  await DriveFlowCrashReporting.bootstrap(() async {
    FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

    await HiveStorage.initialize();
    await initializeSupabase();
    await _restoreSessionIfAvailable();
    await initializeDateFormatting('pt_BR');
    await MaintenanceNotificationService.instance.initialize();

    final container = ProviderContainer();
    await container.read(themeModeProvider.notifier).load();
    container.read(syncWorkerProvider).start();

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const PlatformOAuthDeepLinkListener(
          child: DriveFlowApp(),
        ),
      ),
    );
  });
}

Future<void> _restoreSessionIfAvailable() async {
  final storage = SessionSecureStorage();
  final refreshToken = await storage.readRefreshToken();
  if (refreshToken == null || refreshToken.isEmpty) return;

  try {
    await Supabase.instance.client.auth.setSession(refreshToken);
  } on Object {
    await storage.clear();
  }
}
