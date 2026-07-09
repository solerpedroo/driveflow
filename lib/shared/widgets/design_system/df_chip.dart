import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// Chip de métrica / filtro do Design System v2.
class DfChip extends StatelessWidget {
  const DfChip({
    required this.label,
    required this.value,
    super.key,
    this.accentColor = AppColors.electricTeal,
    this.icon,
    this.onTap,
    this.selected = false,
  });

  final String label;
  final String value;
  final Color accentColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$label: $value',
      button: onTap != null,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdAll,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdAll,
              color: selected
                  ? accentColor.withValues(alpha: 0.15)
                  : AppColors.mutedSurface(theme),
              border: Border.all(
                color: accentColor.withValues(alpha: selected ? 0.45 : 0.25),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: accentColor),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.secondaryLabel(theme),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
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
