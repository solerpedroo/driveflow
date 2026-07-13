import '../constants/ride_platforms.dart';
import 'app_deep_link_action.dart';
import 'app_deep_link_intent.dart';

/// Interpreta URIs internos do app.
abstract final class AppDeepLinkParser {
  static const scheme = 'driveflow';

  static AppDeepLinkIntent? parse(Uri uri) {
    if (uri.scheme != scheme) return null;

    final host = uri.host;
    final segments = uri.pathSegments;

    if (host == 'shift') {
      if (segments.isEmpty) {
        return const AppDeepLinkIntent(action: AppDeepLinkAction.shiftMode);
      }
      return switch (segments.first) {
        'start' => const AppDeepLinkIntent(action: AppDeepLinkAction.shiftStart),
        'history' =>
          const AppDeepLinkIntent(action: AppDeepLinkAction.shiftHistory),
        'analytics' =>
          const AppDeepLinkIntent(action: AppDeepLinkAction.shiftAnalytics),
        'quick-earning' =>
          const AppDeepLinkIntent(action: AppDeepLinkAction.quickEarning),
        _ => const AppDeepLinkIntent(action: AppDeepLinkAction.shiftMode),
      };
    }

    if (host == 'earning' && segments.firstOrNull == 'quick') {
      return const AppDeepLinkIntent(action: AppDeepLinkAction.quickEarning);
    }

    if (host == 'platform' && segments.firstOrNull == 'open') {
      final platformValue = uri.queryParameters['app'];
      if (platformValue == null) return null;
      return AppDeepLinkIntent(
        action: AppDeepLinkAction.openPlatform,
        platform: RidePlatform.fromValue(platformValue),
      );
    }

    return null;
  }
}
