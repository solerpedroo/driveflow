import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/presentation/providers/sync_providers.dart';
import 'core/services/crash_reporting.dart';
import 'core/storage/hive_storage.dart';
import 'core/services/maintenance_notification_service.dart';
import 'core/theme/theme_mode_provider.dart';
import 'supabase_dev_setup.dart';

Future<void> main() async {
  await DriveFlowCrashReporting.bootstrap(() async {
    await HiveStorage.initialize();
    await initializeSupabase();
    await initializeDateFormatting('pt_BR');
    await MaintenanceNotificationService.instance.initialize();

    final container = ProviderContainer();
    await container.read(themeModeProvider.notifier).load();
    container.read(syncWorkerProvider).start();

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const DriveFlowApp(),
      ),
    );
  });
}
