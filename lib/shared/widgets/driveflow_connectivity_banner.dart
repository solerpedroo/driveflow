import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/presentation/providers/sync_providers.dart';
import '../../core/services/sync_status.dart';
import '../../core/theme/app_colors.dart';

/// Banner de conectividade e sincronização no topo do shell.
class DriveFlowConnectivityBanner extends ConsumerWidget {
  const DriveFlowConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineAsync = ref.watch(isOnlineProvider);
    final syncStatusAsync = ref.watch(syncStatusProvider);
    final pendingAsync = ref.watch(pendingSyncCountProvider);

    final online = onlineAsync.valueOrNull ?? true;
    final syncStatus = syncStatusAsync.valueOrNull ?? SyncStatus.idle;
    final pending = pendingAsync.valueOrNull ?? 0;

    String? message;
    IconData icon;
    Color background;
    Color foreground;

    if (!online) {
      message = pending > 0
          ? 'Offline · $pending alteração(ões) aguardando sync'
          : 'Você está offline — dados locais disponíveis';
      icon = Icons.cloud_off_rounded;
      background = AppColors.expenseCoral.withValues(alpha: 0.15);
      foreground = AppColors.expenseCoral;
    } else if (syncStatus == SyncStatus.syncing) {
      message = 'Sincronizando alterações…';
      icon = Icons.sync_rounded;
      background = AppColors.profitGreen.withValues(alpha: 0.12);
      foreground = AppColors.profitGreen;
    } else if (syncStatus == SyncStatus.failed) {
      message = 'Falha ao sincronizar — tente novamente online';
      icon = Icons.error_outline_rounded;
      background = AppColors.expenseCoral.withValues(alpha: 0.12);
      foreground = AppColors.expenseCoral;
    } else if (pending > 0) {
      message = '$pending alteração(ões) na fila';
      icon = Icons.cloud_queue_rounded;
      background = Theme.of(context).colorScheme.surfaceContainerHighest;
      foreground = AppColors.secondaryLabel(Theme.of(context));
    } else {
      return const SizedBox.shrink();
    }

    return Semantics(
      label: message,
      child: Material(
        color: background,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: foreground,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
