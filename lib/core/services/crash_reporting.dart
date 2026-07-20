import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Captura erros fatais e do framework — Sentry em release quando configurado.
abstract final class DriveFlowCrashReporting {
  static const _sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static Future<void> bootstrap(Future<void> Function() appRunner) async {
    if (_sentryDsn.isNotEmpty && !kDebugMode) {
      await SentryFlutter.init(
        (options) {
          options.dsn = _sentryDsn;
          options.tracesSampleRate = 0.2;
          options.beforeSend = (event, hint) => _scrubEvent(event);
        },
        appRunner: () async {
          _installFrameworkHandlers();
          await appRunner();
        },
      );
      return;
    }

    await runZonedGuarded(
      () async {
        _installFrameworkHandlers();
        await appRunner();
      },
      _recordError,
    );
  }

  static void _installFrameworkHandlers() {
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
  }

  static SentryEvent? _scrubEvent(SentryEvent event) {
    final message = event.message?.formatted;
    if (message != null &&
        (message.contains('Bearer ') || message.contains('refresh_token'))) {
      return null;
    }
    return event;
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
      return;
    }

    if (_sentryDsn.isNotEmpty) {
      unawaited(Sentry.captureException(error, stackTrace: stack));
    }
  }
}
