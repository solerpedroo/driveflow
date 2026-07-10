import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../providers/platform_sync_logs_providers.dart';

/// Painel de logs de sincronização (auditoria).
class PlatformSyncLogPanel extends ConsumerWidget {
  const PlatformSyncLogPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logs = ref.watch(platformSyncLogsProvider).valueOrNull ?? [];
    if (logs.isEmpty) return const SizedBox.shrink();

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Histórico de sincronizações',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final log in logs.take(5)) ...[
            Row(
              children: [
                Icon(
                  log.isSuccess
                      ? Icons.check_circle
                      : log.isPartial
                          ? Icons.info_outline
                          : Icons.warning_amber,
                  size: 16,
                  color: log.isSuccess
                      ? AppColors.profitGreen
                      : log.isPartial
                          ? AppColors.skyBlue
                          : AppColors.warningAmber,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${log.platform.label} · ${log.tripsImported} corridas · '
                    '${log.earningsImported} ganhos',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Text(
                  log.triggerSource,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                  ),
                ),
              ],
            ),
            if (log.message != null)
              Text(
                log.message!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.secondaryLabel(theme),
                ),
              ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}
