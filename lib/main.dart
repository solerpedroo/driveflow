import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/theme/theme_mode_provider.dart';
import 'supabase_dev_setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeSupabase();
  await initializeDateFormatting('pt_BR');

  final container = ProviderContainer();
  await container.read(themeModeProvider.notifier).load();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const DriveFlowApp(),
    ),
  );
}
