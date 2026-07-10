import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Cabeçalho de seção estilo iOS — uppercase muted + título.
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
                    eyebrow!.toUpperCase(),
                    style: AppTypography.iosSectionHeader(brightness).copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
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

/// Título grande estilo iOS Large Title.
///
/// Preferir [DfScreenTitleRow] nas abas do shell Mescla.
@Deprecated('Use DfScreenTitleRow no padrão Mescla')
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
            Text(
              eyebrow!.toUpperCase(),
              style: AppTypography.iosSectionHeader(brightness).copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(title, style: AppTypography.iosLargeTitle(brightness)),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.md),
            subtitle!,
          ],
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
