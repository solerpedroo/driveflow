import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Cabeçalho de seção premium — label caps + linha de marca.
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
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.brandBlue.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(eyebrow!, style: AppTypography.labelCaps(brightness)),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          if (action != null)
            TextButton(
              onPressed: action,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.brandBlue,
              ),
              child: Text(
                actionLabel ?? 'Ver mais',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

/// Título de tela editorial — meta + headline.
class DfScreenTitle extends StatelessWidget {
  const DfScreenTitle({
    required this.title,
    super.key,
    this.subtitle,
    this.eyebrow,
  });

  final String title;
  final Widget? subtitle;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.screenTop,
        AppSpacing.screenHorizontal,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null) ...[
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.brandBlue.withValues(alpha: 0.50),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(eyebrow!, style: AppTypography.labelCaps(brightness)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.md),
            subtitle!,
          ],
        ],
      ),
    );
  }
}
