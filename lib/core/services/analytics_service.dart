import 'package:flutter/foundation.dart';

/// Eventos de produto registrados para analytics (debug log + hook futuro Firebase).
abstract final class DriveFlowAnalytics {
  static final instance = _DriveFlowAnalyticsImpl();

  static void logEvent(String name, [Map<String, Object?> params = const {}]) {
    instance.track(name, params);
  }
}

final class _DriveFlowAnalyticsImpl {
  void track(String name, Map<String, Object?> params) {
    if (kDebugMode) {
      debugPrint('[Analytics] $name ${params.isEmpty ? '' : params}');
    }
  }
}
