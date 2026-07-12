import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_elevation.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/df_haptics.dart';

/// Hero de KPI — DNA Wallet (navy→blue), olho dentro do card.
class DfHeroWealthCard extends StatelessWidget {
  const DfHeroWealthCard({
    required this.label,
    required this.value,
    super.key,
    this.badge,
    this.footer,
    this.hideValue = false,
    this.onToggleVisibility,
  });

  final String label;
  final String value;
  final String? badge;
  final Widget? footer;
  final bool hideValue;
  final VoidCallback? onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final displayValue = hideValue ? 'R\$ ••••••' : value;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        gradient: AppGradients.heroWealth,
        boxShadow: [
          BoxShadow(
            color: AppColors.brandBlue.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
          ...AppElevation.heroDepth(brightness),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.xlAll,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.labelCaps(brightness).copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ),
                  if (onToggleVisibility != null) ...[
                    IconButton(
                      onPressed: () {
                        DfHaptics.light();
                        onToggleVisibility!();
                      },
                      tooltip:
                          hideValue ? 'Mostrar valores' : 'Ocultar valores',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      icon: Icon(
                        hideValue
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 22,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
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
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                displayValue,
                style: AppTypography.metric(
                  brightness,
                  fontSize: 40,
                  color: Colors.white,
                ),
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
      ),
    );
  }
}

/// Botão de visibilidade dos valores (fora do hero — telas legadas).
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

/// Título de tela — opcionalmente com toggle (preferir olho no hero).
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
    final brightness = theme.brightness;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.iosHeadline(brightness).copyWith(
              fontSize: 22,
              height: 1.2,
              letterSpacing: -0.4,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
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
