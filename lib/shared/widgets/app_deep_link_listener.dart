import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/deep_links/app_deep_link_parser.dart';
import '../../core/services/app_deep_link_handler.dart';
import '../../core/services/maintenance_notification_service.dart';

/// Escuta `driveflow://` e toques em notificações com payload.
class AppDeepLinkListener extends ConsumerStatefulWidget {
  const AppDeepLinkListener({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<AppDeepLinkListener> createState() =>
      _AppDeepLinkListenerState();
}

class _AppDeepLinkListenerState extends ConsumerState<AppDeepLinkListener> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  final _handled = <String>{};

  @override
  void initState() {
    super.initState();
    MaintenanceNotificationService.onNotificationTap = _onNotificationTap;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final initial = await _appLinks.getInitialLink();
    if (initial != null) {
      await _handleUri(initial);
    }
    _subscription = _appLinks.uriLinkStream.listen(_handleUri);
  }

  Future<void> _handleUri(Uri uri) async {
    final intent = AppDeepLinkParser.parse(uri);
    if (intent == null) return;

    final fingerprint = uri.toString();
    if (_handled.contains(fingerprint)) return;
    _handled.add(fingerprint);

    if (!mounted) return;
    await AppDeepLinkHandler.handle(
      ref: ref,
      router: GoRouter.of(context),
      intent: intent,
    );
  }

  void _onNotificationTap(String? payload) {
    if (!mounted) return;
    AppDeepLinkHandler.handlePayload(
      ref: ref,
      router: GoRouter.of(context),
      payload: payload,
    );
  }

  @override
  void dispose() {
    if (MaintenanceNotificationService.onNotificationTap == _onNotificationTap) {
      MaintenanceNotificationService.onNotificationTap = null;
    }
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
