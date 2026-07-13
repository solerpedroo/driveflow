import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_cupertino_theme.dart';
import 'core/theme/app_scroll_behavior.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/shift_notification_bootstrap.dart';

/// Raiz do app — Material + Cupertino unificados (HIG Apple).
class DriveFlowApp extends ConsumerWidget {
  const DriveFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return ShiftNotificationBootstrap(
      child: CupertinoTheme(
        data: themeMode == ThemeMode.dark
            ? buildDriveFlowCupertinoDarkTheme()
            : buildDriveFlowCupertinoLightTheme(),
        child: MaterialApp.router(
          title: 'DriveFlow',
          debugShowCheckedModeBanner: false,
          scrollBehavior: const AppScrollBehavior(),
          themeMode: themeMode,
          theme: buildDriveFlowLightTheme(),
          darkTheme: buildDriveFlowDarkTheme(),
          routerConfig: router,
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
  }
}
