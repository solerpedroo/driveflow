import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Cabeçalho de seção — eyebrow sentence-case + título.
class DfSectionHeader extends StatelessWidget {
  const DfSectionHeader({
    required this.title,
    super.key,
    this.action,
    this.actionLabel,
    this.eyebrow,
  });

  final String title;
  final VoidCallback? action;
  final String? actionLabel;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Semantics(
      header: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[
                  Text(
                    eyebrow!,
                    style: AppTypography.iosSectionHeader(brightness).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  title,
                  style: AppTypography.iosHeadline(brightness).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (action != null)
            CupertinoStyleTextButton(
              onPressed: action,
              label: actionLabel ?? 'Ver mais',
            ),
        ],
      ),
    );
  }
}

/// Link azul system estilo iOS.
class CupertinoStyleTextButton extends StatelessWidget {
  const CupertinoStyleTextButton({
    required this.onPressed,
    required this.label,
    super.key,
  });

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.brandBlue,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(
        label,
        style: AppTypography.iosBody(Theme.of(context).brightness).copyWith(
          color: AppColors.brandBlue,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
