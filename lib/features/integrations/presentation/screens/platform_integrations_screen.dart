import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_expandable_list_section.dart';
import '../../../../shared/widgets/design_system/df_quick_actions.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';
import '../../domain/entities/platform_connection_entity.dart';
import '../../domain/services/platform_catalog.dart';
import '../providers/integrations_providers.dart';
import '../../domain/entities/platform_cockpit_tab.dart';
import '../providers/platform_cockpit_providers.dart';
import '../widgets/platform_cockpit_panel.dart';
import '../widgets/platform_connect_sheet.dart';
import '../widgets/platform_connection_card.dart';
import '../widgets/platform_recent_trips_card.dart';
import '../widgets/platform_sync_log_panel.dart';

/// Hub de integrações e cockpit multi-app.
class PlatformIntegrationsScreen extends ConsumerStatefulWidget {
  const PlatformIntegrationsScreen({
    super.key,
    this.initialCockpitTab = PlatformCockpitTab.today,
  });

  final PlatformCockpitTab initialCockpitTab;

  @override
  ConsumerState<PlatformIntegrationsScreen> createState() =>
      _PlatformIntegrationsScreenState();
}

class _PlatformIntegrationsScreenState
    extends ConsumerState<PlatformIntegrationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(platformCockpitTabProvider.notifier).state =
          widget.initialCockpitTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
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
              final error =
                  ref.read(platformIntegrationControllerProvider).error;
              final message = error is Failure
                  ? error.message
                  : 'Não foi possível iniciar a conexão.';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
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
            ? 'Não foi possível atualizar ${platform.label}.'
            : result.hasImports
                ? '${result.tripsImported} corridas e ${result.earningsImported} '
                    'ganhos importados de ${platform.label}.'
                : result.message ??
                    'Atualização concluída (${result.skippedCount} ignorados).';
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
                  ? 'Nenhuma plataforma atualizada.'
                  : '${result.tripsImported} corridas e ${result.earningsImported} '
                      'ganhos importados no total.',
            ),
          ),
        );
      }
    }

    return DfSubpageScaffold(
      title: 'Cockpit',
      onRefresh: () async {
        await ref
            .read(platformIntegrationRepositoryProvider)
            .fetchConnections();
      },
      children: [
        DfCard(
          variant: DfCardVariant.elevated,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandBlue.withValues(alpha: 0.10),
                ),
                child: const Icon(
                  Icons.hub_rounded,
                  color: AppColors.brandBlue,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cockpit multi-app',
                      style: AppTypography.labelCaps(brightness),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Decisão inteligente de turno',
                      style: AppTypography.iosHeadline(brightness).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$connectedCount de ${PlatformCatalog.integratablePlatforms.length} '
                      'plataformas conectadas',
                      style: AppTypography.iosFootnote(brightness),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        DfQuickActions(
          actions: [
            DfQuickAction(
              icon: Icons.sync_rounded,
              label: 'Atualizar',
              onTap: isBusy ? () {} : syncAll,
            ),
            DfQuickAction(
              icon: Icons.route_rounded,
              label: 'Corridas',
              onTap: () => context.push(AppRoutes.platformTripHistory),
            ),
            DfQuickAction(
              icon: Icons.upload_file_rounded,
              label: 'Importar',
              onTap: () => context.push(AppRoutes.importStatement),
            ),
            DfQuickAction(
              icon: Icons.bar_chart_rounded,
              label: 'Análises',
              onTap: () => context.push(AppRoutes.analytics),
            ),
          ],
        ),
        const PlatformCockpitPanel(),
        const PlatformRecentTripsCard(),
        const PlatformSyncLogPanel(),
        DfExpandableListSection(
          title: 'Plataformas',
          eyebrow: 'Conexões',
          itemCount: PlatformCatalog.integratablePlatforms.length,
          previewCount: PlatformCatalog.integratablePlatforms.length,
          spacing: AppSpacing.md,
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
          variant: DfCardVariant.elevated,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alternativa',
                style: AppTypography.labelCaps(brightness),
              ),
              const SizedBox(height: 4),
              Text(
                'Sem conexão automática?',
                style: AppTypography.iosHeadline(brightness).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Importe extratos do banco ou cadastre ganhos manualmente.',
                style: AppTypography.iosBody(brightness).copyWith(
                  color: AppColors.secondaryLabel(Theme.of(context)),
                  height: 1.4,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              DfButton(
                label: 'Importar extrato do banco',
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
