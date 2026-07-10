import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_elevation.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Hero de KPI — profundidade Wallet (navy→blue), tipografia dominante.
class DfHeroWealthCard extends StatelessWidget {
  const DfHeroWealthCard({
    required this.label,
    required this.value,
    super.key,
    this.badge,
    this.footer,
    this.hideValue = false,
  });

  final String label;
  final String value;
  final String? badge;
  final Widget? footer;
  final bool hideValue;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final displayValue = hideValue ? 'R\$ ••••••' : value;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        gradient: AppGradients.heroWealth,
        boxShadow: AppElevation.heroDepth(brightness),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelCaps(brightness).copyWith(
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    displayValue,
                    style: AppTypography.metric(
          brightness,
          fontSize: 36,
          color: Colors.white,
        ),
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Text(
                      hideValue ? '•••' : badge!,
                      style: AppTypography.iosFootnote(brightness).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (footer != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Divider(
                height: 1,
                thickness: 0.5,
                color: Colors.white.withValues(alpha: 0.16),
              ),
              const SizedBox(height: AppSpacing.md),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Botão de visibilidade dos valores.
class DfValueVisibilityButton extends StatelessWidget {
  const DfValueVisibilityButton({
    required this.hidden,
    required this.onToggle,
    super.key,
  });

  final bool hidden;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: onToggle,
      icon: Icon(
        hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.secondaryLabel(theme),
      ),
      tooltip: hidden ? 'Mostrar valores' : 'Ocultar valores',
    );
  }
}

/// Título de tela com toggle de visibilidade.
class DfScreenTitleRow extends StatelessWidget {
  const DfScreenTitleRow({
    required this.title,
    super.key,
    this.hidden,
    this.onToggleVisibility,
  });

  final String title;
  final bool? hidden;
  final VoidCallback? onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
        ),
        if (hidden != null && onToggleVisibility != null)
          DfValueVisibilityButton(
            hidden: hidden!,
            onToggle: onToggleVisibility!,
          ),
      ],
    );
  }
}
