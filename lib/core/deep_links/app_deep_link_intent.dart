import '../constants/ride_platforms.dart';
import 'app_deep_link_action.dart';

/// Intenção resolvida a partir de um URI `driveflow://`.
class AppDeepLinkIntent {
  const AppDeepLinkIntent({
    required this.action,
    this.platform,
  });

  final AppDeepLinkAction action;
  final RidePlatform? platform;
}
