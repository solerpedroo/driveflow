import 'package:flutter/material.dart';

import '../../../../core/constants/platform_app_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/platform_brand_icon.dart';
import '../../domain/entities/shift_plan_adherence.dart';

/// Bloco atual do plano + CTA para abrir o app recomendado.
class ShiftPlanProgressRow extends StatelessWidget {
  const ShiftPlanProgressRow({
    required this.adherence,
    super.key,
  });

  final ShiftPlanAdherence adherence;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final block = adherence.currentBlock;
    if (block == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (PlatformBrandIcon.hasBrandAsset(block.platform))
              PlatformBrandIcon(
                platform: block.platform,
                size: 32,
                borderRadius: 8,
              ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agora: ${block.platform.label}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${block.timeRange} · ${block.reason}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryLabel(theme),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (adherence.shouldSwitch &&
            adherence.recommendedPlatform != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sugestão: troque para ${adherence.recommendedPlatform!.label}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.warningAmber,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        DfButton(
          label: adherence.shouldSwitch && adherence.recommendedPlatform != null
              ? 'Abrir ${adherence.recommendedPlatform!.label}'
              : 'Abrir ${block.platform.label}',
          icon: Icons.open_in_new_rounded,
          onPressed: () async {
            DfHaptics.light();
            final platform = adherence.shouldSwitch
                ? adherence.recommendedPlatform!
                : block.platform;
            final opened = await PlatformAppLauncher.open(platform);
            if (!context.mounted || opened) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Não foi possível abrir ${platform.label}. '
                  'Abra o app manualmente.',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
