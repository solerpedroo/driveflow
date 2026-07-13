import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/deep_links/app_deep_link_action.dart';
import '../../../../core/deep_links/app_deep_link_intent.dart';
import '../../../../core/deep_links/app_deep_link_routes.dart';
import '../../../../core/services/app_deep_link_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';

/// Atalhos e deep links para automação do modo turno.
class ShiftShortcutsCard extends ConsumerWidget {
  const ShiftShortcutsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isTaxi = ref.watch(isTaxiDriverProvider);
    if (isTaxi) return const SizedBox.shrink();

    final shortcuts = [
      (
        intent: const AppDeepLinkIntent(action: AppDeepLinkAction.shiftStart),
        icon: Icons.play_arrow_rounded,
        label: 'Iniciar turno',
      ),
      (
        intent: const AppDeepLinkIntent(action: AppDeepLinkAction.quickEarning),
        icon: Icons.bolt_rounded,
        label: 'Ganho rápido',
      ),
      (
        intent: const AppDeepLinkIntent(action: AppDeepLinkAction.shiftHistory),
        icon: Icons.history_rounded,
        label: 'Histórico',
      ),
      (
        intent: const AppDeepLinkIntent(action: AppDeepLinkAction.shiftAnalytics),
        icon: Icons.bar_chart_rounded,
        label: 'Analytics',
      ),
    ];

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Atalhos e automação',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Toque para abrir ou copiar o link driveflow:// para Shortcuts/Siri',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryLabel(theme),
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final shortcut in shortcuts)
            _ShortcutRow(
              icon: shortcut.icon,
              label: shortcut.label,
              onTap: () => _runShortcut(context, ref, shortcut.intent),
            ),
        ],
      ),
    );
  }

  Future<void> _runShortcut(
    BuildContext context,
    WidgetRef ref,
    AppDeepLinkIntent intent,
  ) async {
    DfHaptics.light();

    final uri = switch (intent.action) {
      AppDeepLinkAction.shiftStart => AppDeepLinkRoutes.shiftStart(),
      AppDeepLinkAction.quickEarning => AppDeepLinkRoutes.quickEarning(),
      AppDeepLinkAction.shiftHistory => AppDeepLinkRoutes.shiftHistory(),
      AppDeepLinkAction.shiftAnalytics => AppDeepLinkRoutes.shiftAnalytics(),
      _ => AppDeepLinkRoutes.shiftMode(),
    };

    await Clipboard.setData(ClipboardData(text: uri.toString()));
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copiado. Abrindo atalho…'),
        duration: Duration(seconds: 2),
      ),
    );

    await AppDeepLinkHandler.handle(
      ref: ref,
      router: GoRouter.of(context),
      intent: intent,
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.brandBlue),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.link_rounded,
                size: 18,
                color: AppColors.secondaryLabel(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
