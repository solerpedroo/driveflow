import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../constants/ride_platforms.dart';
import '../../features/dashboard/presentation/providers/dashboard_providers.dart';
import '../../features/earnings/presentation/providers/earnings_providers.dart';
import '../../features/integrations/domain/services/platform_oauth_service.dart';
import '../../features/integrations/domain/services/platform_catalog.dart';
import '../../features/integrations/presentation/providers/integrations_providers.dart';

/// Escuta o retorno OAuth das plataformas e dispara sync automático.
class PlatformOAuthDeepLinkListener extends ConsumerStatefulWidget {
  const PlatformOAuthDeepLinkListener({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<PlatformOAuthDeepLinkListener> createState() =>
      _PlatformOAuthDeepLinkListenerState();
}

class _PlatformOAuthDeepLinkListenerState
    extends ConsumerState<PlatformOAuthDeepLinkListener> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  final _handled = <String>{};

  @override
  void initState() {
    super.initState();
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
    if (uri.scheme != PlatformOAuthService.redirectScheme) return;
    if (uri.host != PlatformOAuthService.redirectPath) return;

    final fingerprint =
        '${uri.host}|${uri.queryParameters['status']}|${uri.queryParameters['platform']}|${uri.queryParameters['message']}';
    if (_handled.contains(fingerprint)) return;
    _handled.add(fingerprint);

    final status = uri.queryParameters['status'];
    final platformValue = uri.queryParameters['platform'];
    final message = uri.queryParameters['message'];
    final platform = _parseIntegratablePlatform(platformValue);

    if (!mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    final router = GoRouter.of(context);

    if (status == 'connected' && platform != null) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text('${platform.label} conectado. Atualizando ganhos…'),
        ),
      );

      router.go(AppRoutes.platformIntegrations);

      final result = await ref
          .read(platformIntegrationControllerProvider.notifier)
          .sync(platform);

      ref.invalidate(earningsStreamProvider);
      ref.invalidate(earningsListProvider);
      ref.invalidate(earningsTotalProvider);
      ref.invalidate(dashboardMonthProvider);
      ref.invalidate(dashboardSnapshotProvider);

      if (!mounted) return;

      final syncMessage = result == null
          ? 'Conectado, mas não foi possível atualizar ${platform.label}.'
          : result.hasImports
              ? '${result.tripsImported} corridas e ${result.earningsImported} '
                  'ganhos importados de ${platform.label}.'
              : result.message ??
                  'Conexão concluída. Nenhum ganho novo no período.';

      messenger?.showSnackBar(SnackBar(content: Text(syncMessage)));
      return;
    }

    if (status == 'error') {
      router.go(AppRoutes.platformIntegrations);
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            message ?? 'Não foi possível conectar ${platform?.label ?? 'o app'}.',
          ),
        ),
      );
    }
  }

  RidePlatform? _parseIntegratablePlatform(String? value) {
    if (value == null) return null;
    for (final platform in PlatformCatalog.integratablePlatforms) {
      if (platform.value == value) return platform;
    }
    return null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
