import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

/// Chip de métrica para dashboard e previews de design system.
class DriveFlowMetricChip extends StatelessWidget {
  const DriveFlowMetricChip({
    required this.label,
    required this.value,
    super.key,
    this.accentColor = AppColors.electricTeal,
    this.icon,
  });

  final String label;
  final String value;
  final Color accentColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$label: $value',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.mutedSurface(theme),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 8),
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
    );
  }
}
