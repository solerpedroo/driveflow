import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// Botão de ação em pill — grade 2×2 no hero (Mescla Carteira).
class DfPillActionButton extends StatelessWidget {
  const DfPillActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
    this.accentColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? AppColors.brandBlue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.secondaryGrouped(theme.brightness),
            borderRadius: AppRadius.lgAll,
            border: Border.all(
              color: AppColors.border(theme).withValues(alpha: 0.35),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Grade 2×2 de ações rápidas.
class DfPillActionGrid extends StatelessWidget {
  const DfPillActionGrid({
    required this.actions,
    super.key,
  });

  final List<DfPillActionButton> actions;

  @override
  Widget build(BuildContext context) {
    assert(actions.length == 4, 'DfPillActionGrid espera exatamente 4 ações');

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: actions[0]),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: actions[1]),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(child: actions[2]),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: actions[3]),
          ],
        ),
      ],
    );
  }
}
