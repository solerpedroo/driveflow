import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../deep_links/app_deep_link_intent.dart';

class PendingAppDeepLinkController extends Notifier<AppDeepLinkIntent?> {
  @override
  AppDeepLinkIntent? build() => null;

  void set(AppDeepLinkIntent intent) => state = intent;

  void clear() => state = null;
}

final pendingAppDeepLinkProvider =
    NotifierProvider<PendingAppDeepLinkController, AppDeepLinkIntent?>(
  PendingAppDeepLinkController.new,
);
