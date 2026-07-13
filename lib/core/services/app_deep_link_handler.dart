import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../constants/platform_app_launcher.dart';
import '../constants/ride_platforms.dart';
import '../deep_links/app_deep_link_action.dart';
import '../deep_links/app_deep_link_intent.dart';
import '../deep_links/app_deep_link_parser.dart';
import '../deep_links/app_deep_link_routes.dart';
import '../presentation/providers/app_deep_link_providers.dart';

/// Executa navegação e efeitos colaterais de deep links internos.
abstract final class AppDeepLinkHandler {
  static Future<void> handle({
    required WidgetRef ref,
    required GoRouter router,
    required AppDeepLinkIntent intent,
  }) async {
    switch (intent.action) {
      case AppDeepLinkAction.shiftMode:
        router.push(AppRoutes.shiftMode);
      case AppDeepLinkAction.shiftStart:
        ref.read(pendingAppDeepLinkProvider.notifier).set(intent);
        router.push(AppRoutes.shiftMode);
      case AppDeepLinkAction.quickEarning:
        ref.read(pendingAppDeepLinkProvider.notifier).set(intent);
        router.push(AppRoutes.shiftMode);
      case AppDeepLinkAction.shiftHistory:
        router.push(AppRoutes.shiftHistory);
      case AppDeepLinkAction.shiftAnalytics:
        router.push(AppRoutes.shiftAnalytics);
      case AppDeepLinkAction.openPlatform:
        final platform = intent.platform;
        if (platform != null) {
          await PlatformAppLauncher.open(platform);
        }
    }
  }

  static Future<void> handlePayload({
    required WidgetRef ref,
    required GoRouter router,
    required String? payload,
  }) async {
    if (payload == null || payload.isEmpty) return;
    final uri = Uri.tryParse(payload);
    if (uri == null) return;
    final intent = AppDeepLinkParser.parse(uri);
    if (intent == null) return;
    await handle(ref: ref, router: router, intent: intent);
  }

  static String payloadFor(AppDeepLinkAction action, {String? platformValue}) {
    final uri = switch (action) {
      AppDeepLinkAction.shiftMode => AppDeepLinkRoutes.shiftMode(),
      AppDeepLinkAction.shiftStart => AppDeepLinkRoutes.shiftStart(),
      AppDeepLinkAction.quickEarning => AppDeepLinkRoutes.quickEarning(),
      AppDeepLinkAction.shiftHistory => AppDeepLinkRoutes.shiftHistory(),
      AppDeepLinkAction.shiftAnalytics => AppDeepLinkRoutes.shiftAnalytics(),
      AppDeepLinkAction.openPlatform => platformValue == null
          ? null
          : AppDeepLinkRoutes.openPlatform(
              RidePlatform.fromValue(platformValue),
            ),
    };
    return uri?.toString() ?? '';
  }
}
