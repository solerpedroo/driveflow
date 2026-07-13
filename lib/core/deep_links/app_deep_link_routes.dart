import '../../core/constants/app_constants.dart';
import '../../core/constants/ride_platforms.dart';
import 'app_deep_link_action.dart';

/// Constrói URIs `driveflow://` para atalhos e automações.
abstract final class AppDeepLinkRoutes {
  static Uri shiftMode() => Uri(
        scheme: kAppDeepLinkScheme,
        host: 'shift',
      );

  static Uri shiftStart() => Uri(
        scheme: kAppDeepLinkScheme,
        host: 'shift',
        path: '/start',
      );

  static Uri quickEarning() => Uri(
        scheme: kAppDeepLinkScheme,
        host: 'earning',
        path: '/quick',
      );

  static Uri shiftHistory() => Uri(
        scheme: kAppDeepLinkScheme,
        host: 'shift',
        path: '/history',
      );

  static Uri shiftAnalytics() => Uri(
        scheme: kAppDeepLinkScheme,
        host: 'shift',
        path: '/analytics',
      );

  static Uri openPlatform(RidePlatform platform) => Uri(
        scheme: kAppDeepLinkScheme,
        host: 'platform',
        path: '/open',
        queryParameters: {'app': platform.value},
      );

  static String labelFor(AppDeepLinkAction action) {
    return switch (action) {
      AppDeepLinkAction.shiftMode => 'Modo turno',
      AppDeepLinkAction.shiftStart => 'Iniciar turno',
      AppDeepLinkAction.quickEarning => 'Ganho rápido',
      AppDeepLinkAction.shiftHistory => 'Histórico de turnos',
      AppDeepLinkAction.shiftAnalytics => 'Analytics de turnos',
      AppDeepLinkAction.openPlatform => 'Abrir app de corrida',
    };
  }
}
