import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_expandable_list_section.dart';
import '../../../../shared/widgets/design_system/df_pill_action_button.dart';
import '../../../../shared/widgets/design_system/df_section_header.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';
import '../../domain/entities/platform_connection_entity.dart';
import '../../domain/services/platform_catalog.dart';
import '../providers/integrations_providers.dart';
import '../widgets/platform_connect_sheet.dart';
import '../widgets/platform_connection_card.dart';
import '../widgets/platform_insights_panel.dart';
import '../widgets/platform_recent_trips_card.dart';
import '../widgets/platform_sync_log_panel.dart';

/// Hub de integrações — layout Mescla com hero, ações e seções.
class PlatformIntegrationsScreen extends ConsumerWidget {
  const PlatformIntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connections = ref.watch(platformConnectionsProvider).valueOrNull;
    final mutation = ref.watch(platformIntegrationControllerProvider);
    final isBusy = mutation.isLoading;
    final connectedCount = (connections ?? const <PlatformConnectionEntity>[])
        .where((c) => c.isConnected)
        .length;

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

    return DfSubpageScaffold(
      title: 'Apps conectados',
      onRefresh: () async {
        await ref.read(platformIntegrationRepositoryProvider).fetchConnections();
      },
      children: [
        DfCard(
          variant: DfCardVariant.hero,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.brandBlue, AppColors.profitGreen],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.hub_rounded, color: Colors.white),
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
                      '$connectedCount de ${PlatformCatalog.integratablePlatforms.length} '
                      'plataformas conectadas',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryLabel(theme),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        DfPillActionGrid(
          actions: [
            DfPillActionButton(
              icon: Icons.sync_rounded,
              label: 'Sync tudo',
              onTap: isBusy ? null : syncAll,
            ),
            DfPillActionButton(
              icon: Icons.route_outlined,
              label: 'Corridas',
              onTap: () => context.push(AppRoutes.platformTripHistory),
            ),
            DfPillActionButton(
              icon: Icons.upload_file_outlined,
              label: 'Importar',
              onTap: () => context.push(AppRoutes.importStatement),
            ),
            DfPillActionButton(
              icon: Icons.bar_chart_rounded,
              label: 'Análises',
              onTap: () => context.push(AppRoutes.analytics),
            ),
          ],
        ),
        const PlatformInsightsPanel(),
        const PlatformRecentTripsCard(),
        const PlatformSyncLogPanel(),
        DfExpandableListSection(
          title: 'Plataformas',
          eyebrow: 'Conexões',
          itemCount: PlatformCatalog.integratablePlatforms.length,
          previewCount: PlatformCatalog.integratablePlatforms.length,
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
        DfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DfSectionHeader(
                title: 'Sem API ainda?',
                eyebrow: 'Alternativa',
              ),
              Text(
                'Importe extratos do banco ou cadastre ganhos manualmente.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryLabel(theme),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              DfButton(
                label: 'Importar extrato CSV/OFX',
                icon: Icons.upload_file_outlined,
                variant: DfButtonVariant.outlined,
                onPressed: () => context.push(AppRoutes.importStatement),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
