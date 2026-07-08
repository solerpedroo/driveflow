import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Captura erros fatais e do framework (preparado para Crashlytics).
abstract final class DriveFlowCrashReporting {
  static Future<void> bootstrap(Future<void> Function() runApp) async {
    await runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();

        FlutterError.onError = (details) {
          FlutterError.presentError(details);
          _recordError(
            details.exception,
            details.stack ?? StackTrace.current,
            reason: details.context?.toString(),
          );
        };

        PlatformDispatcher.instance.onError = (error, stack) {
          _recordError(error, stack);
          return true;
        };

        await runApp();
      },
      (error, stack) => _recordError(error, stack),
    );
  }

  static void _recordError(
    Object error,
    StackTrace stack, {
    String? reason,
  }) {
    if (kDebugMode) {
      debugPrint('[Crash] $error');
      if (reason != null) debugPrint('[Crash] context: $reason');
      debugPrintStack(stackTrace: stack);
    }
  }
}
