import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_elevation.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Hero gradiente — KPI principal + badge opcional + rodapé (Mescla patrimônio).
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
        boxShadow: AppElevation.brandGlow(brightness),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -28,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTypography.labelCaps(brightness).copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        displayValue,
                        style: AppTypography.iosLargeTitle(brightness).copyWith(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
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
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Text(
                          hideValue ? '•••' : badge!,
                          style: themeFootnote(brightness).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (footer != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  footer!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static TextStyle themeFootnote(Brightness brightness) {
    return AppTypography.iosFootnote(brightness);
  }
}

/// Botão de visibilidade dos valores (Mescla).
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

/// Título de tela com toggle de visibilidade (Mescla).
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
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
