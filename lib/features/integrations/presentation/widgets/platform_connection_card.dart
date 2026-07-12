import 'package:flutter/material.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/platform_brand_icon.dart';
import '../../domain/entities/integration_status.dart';
import '../../domain/entities/platform_catalog_entry.dart';
import '../../domain/entities/platform_connection_entity.dart';
import '../../domain/services/platform_catalog.dart';

/// Card de conexão para Uber, 99 ou InDrive.
class PlatformConnectionCard extends StatelessWidget {
  const PlatformConnectionCard({
    required this.entry,
    required this.connection,
    required this.isBusy,
    required this.onConnect,
    required this.onDisconnect,
    required this.onSync,
    super.key,
  });

  final PlatformCatalogEntry entry;
  final PlatformConnectionEntity? connection;
  final bool isBusy;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onSync;

  IntegrationStatus get _status =>
      connection?.status ?? IntegrationStatus.disconnected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _status;

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PlatformBrandIcon(
                platform: entry.platform,
                size: 48,
                borderRadius: 12,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.platform.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.tagline,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryLabel(theme),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: entry.capabilities
                .take(4)
                .map(
                  (cap) => Chip(
                    label: Text(cap.label),
                    labelStyle: theme.textTheme.labelSmall,
                    visualDensity: VisualDensity.compact,
                    backgroundColor:
                        AppColors.skyBlue.withValues(alpha: 0.08),
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),
          if (connection?.lastSyncedAt != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Última atualização: ${_formatDate(connection!.lastSyncedAt!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryLabel(theme),
              ),
            ),
          ],
          if (connection?.lastSyncError != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              connection!.lastSyncError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              if (status.isActive ||
                  status == IntegrationStatus.error ||
                  status == IntegrationStatus.tokenExpired) ...[
                Expanded(
                  child: DfButton(
                    label: 'Atualizar',
                    icon: Icons.sync_rounded,
                    variant: DfButtonVariant.tonal,
                    isLoading: isBusy,
                    onPressed: isBusy ? null : onSync,
                  ),
                ),
                const SizedBox(width: 8),
                DfButton(
                  label: 'Desconectar',
                  variant: DfButtonVariant.outlined,
                  isLoading: isBusy,
                  onPressed: isBusy ? null : onDisconnect,
                  expand: false,
                ),
              ] else
                Expanded(
                  child: DfButton(
                    label: status == IntegrationStatus.tokenExpired
                        ? 'Renovar acesso'
                        : status == IntegrationStatus.pending
                            ? 'Continuar conexão'
                            : 'Conectar ${entry.platform.label}',
                    icon: Icons.link_rounded,
                    isLoading: isBusy,
                    onPressed: isBusy ? null : onConnect,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final IntegrationStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, icon) = switch (status) {
      IntegrationStatus.connected => (AppColors.profitGreen, Icons.check_circle),
      IntegrationStatus.pending => (AppColors.warningAmber, Icons.hourglass_top),
      IntegrationStatus.error => (AppColors.expenseCoral, Icons.error_outline),
      IntegrationStatus.tokenExpired => (AppColors.warningAmber, Icons.key_off),
      IntegrationStatus.disconnected => (AppColors.textSecondary, Icons.link_off),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Resolve catálogo + conexão para uma plataforma.
PlatformCatalogEntry catalogFor(RidePlatform platform) =>
    PlatformCatalog.entryFor(platform);
