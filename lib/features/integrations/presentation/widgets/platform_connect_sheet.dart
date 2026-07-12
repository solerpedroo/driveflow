import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/platform_brand_icon.dart';
import '../../domain/entities/platform_catalog_entry.dart';

/// Bottom sheet explicando o fluxo de conexão OAuth/API.
class PlatformConnectSheet extends StatelessWidget {
  const PlatformConnectSheet({
    required this.entry,
    required this.onConfirm,
    super.key,
  });

  final PlatformCatalogEntry entry;
  final VoidCallback onConfirm;

  static Future<void> show(
    BuildContext context, {
    required PlatformCatalogEntry entry,
    required VoidCallback onConfirm,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlatformConnectSheet(
        entry: entry,
        onConfirm: () {
          Navigator.pop(context);
          onConfirm();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              PlatformBrandIcon(
                platform: entry.platform,
                size: 44,
                borderRadius: 12,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Conectar ${entry.platform.label}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'O DriveFlow vai trazer automaticamente:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...entry.capabilities.map(
            (cap) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: AppColors.profitGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(cap.label)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Você será redirecionado para autorizar o acesso. '
            'Seus dados ficam criptografados no servidor — nunca no celular.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryLabel(theme),
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DfButton(
            label: 'Iniciar conexão segura',
            icon: Icons.verified_user_outlined,
            onPressed: onConfirm,
          ),
          const SizedBox(height: 8),
          DfButton(
            label: 'Agora não',
            variant: DfButtonVariant.outlined,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
