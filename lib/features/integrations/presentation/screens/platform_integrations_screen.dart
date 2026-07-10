import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/platform_connection_entity.dart';
import '../../domain/services/platform_catalog.dart';
import '../providers/integrations_providers.dart';
import '../widgets/platform_connect_sheet.dart';
import '../widgets/platform_connection_card.dart';
import '../widgets/platform_insights_panel.dart';
import '../widgets/platform_recent_trips_card.dart';
import '../widgets/platform_sync_log_panel.dart';

/// Hub de integrações Uber, 99 e InDrive.
class PlatformIntegrationsScreen extends ConsumerWidget {
  const PlatformIntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connections = ref.watch(platformConnectionsProvider).valueOrNull;
    final mutation = ref.watch(platformIntegrationControllerProvider);
    final isBusy = mutation.isLoading;

    Future<void> connect(RidePlatform platform) async {
      final entry = PlatformCatalog.entryFor(platform);
      await PlatformConnectSheet.show(
        context,
        entry: entry,
        onConfirm: () async {
          final session = await ref
              .read(platformIntegrationControllerProvider.notifier)
              .startOAuth(platform);
          if (session == null) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Não foi possível iniciar a conexão.'),
                ),
              );
            }
            return;
          }
          final launched = await launchUrl(
            Uri.parse(session.authorizationUrl),
            mode: LaunchMode.externalApplication,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  launched
                      ? 'Autorize ${platform.label} no navegador para conectar.'
                      : 'Abra o link de autorização manualmente.',
                ),
              ),
            );
          }
        },
      );
    }

    Future<void> sync(RidePlatform platform) async {
      final result = await ref
          .read(platformIntegrationControllerProvider.notifier)
          .sync(platform);
      if (context.mounted) {
        final message = result == null
            ? 'Não foi possível sincronizar ${platform.label}.'
            : result.hasImports
                ? '${result.tripsImported} corridas e ${result.earningsImported} '
                    'ganhos importados de ${platform.label}.'
                : result.message ??
                    'Sincronização concluída (${result.skippedCount} ignorados).';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }

    Future<void> syncAll() async {
      final result = await ref
          .read(platformIntegrationControllerProvider.notifier)
          .syncAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result == null
                  ? 'Nenhuma plataforma sincronizada.'
                  : '${result.tripsImported} corridas e ${result.earningsImported} '
                      'ganhos importados no total.',
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Apps conectados'),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(platformIntegrationRepositoryProvider)
              .fetchConnections();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              sliver: SliverToBoxAdapter(
                child: DfCard(
                  variant: DfCardVariant.hero,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.skyBlue, AppColors.profitGreen],
                          ),
                          borderRadius: AppRadius.mdAll,
                        ),
                        child: const Icon(
                          Icons.hub_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seus apps, um só lucro',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Conecte Uber, 99 e InDrive para puxar corridas, '
                              'ganhos e horas automaticamente — sem planilha.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.secondaryLabel(theme),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              sliver: const SliverToBoxAdapter(child: PlatformInsightsPanel()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              sliver: const SliverToBoxAdapter(child: PlatformRecentTripsCard()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              sliver: const SliverToBoxAdapter(child: PlatformSyncLogPanel()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Plataformas',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    DfButton(
                      label: 'Sync tudo',
                      icon: Icons.sync_rounded,
                      variant: DfButtonVariant.tonal,
                      isLoading: isBusy,
                      onPressed: isBusy ? null : syncAll,
                      expand: false,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              sliver: SliverList.separated(
                itemCount: PlatformCatalog.integratablePlatforms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final platform = PlatformCatalog.integratablePlatforms[index];
                  final entry = PlatformCatalog.entryFor(platform);
                  PlatformConnectionEntity? connection;
                  for (final c in connections ?? const <PlatformConnectionEntity>[]) {
                    if (c.platform == platform) {
                      connection = c;
                      break;
                    }
                  }

                  return PlatformConnectionCard(
                    entry: entry,
                    connection: connection,
                    isBusy: isBusy,
                    onConnect: () => connect(platform),
                    onDisconnect: () => ref
                        .read(platformIntegrationControllerProvider.notifier)
                        .disconnect(platform),
                    onSync: () => sync(platform),
                  );
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              sliver: SliverToBoxAdapter(
                child: DfCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sem API ainda?',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Enquanto a conexão oficial não estiver ativa, importe '
                        'extratos do banco ou cadastre ganhos manualmente.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryLabel(theme),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DfButton(
                        label: 'Importar extrato CSV/OFX',
                        icon: Icons.upload_file_outlined,
                        variant: DfButtonVariant.outlined,
                        onPressed: () =>
                            context.push(AppRoutes.importStatement),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
