import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Seção agrupada estilo iOS Settings — header, card inset, footer.
class DfGroupedSection extends StatelessWidget {
  const DfGroupedSection({
    required this.children,
    super.key,
    this.header,
    this.footer,
    this.margin = const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
  });

  final String? header;
  final String? footer;
  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                header!.toUpperCase(),
                style: AppTypography.iosSectionHeader(brightness).copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.secondaryGrouped(brightness),
              borderRadius: AppRadius.grouped,
            ),
            child: ClipRRect(
              borderRadius: AppRadius.grouped,
              child: Column(
                children: _withSeparators(context, children),
              ),
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                footer!,
                style: AppTypography.iosFootnote(brightness),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _withSeparators(BuildContext context, List<Widget> items) {
    if (items.length <= 1) return items;

    final theme = Theme.of(context);
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(
          Divider(
            height: 0.5,
            thickness: 0.5,
            indent: 16,
            color: AppColors.separator(theme),
          ),
        );
      }
    }
    return result;
  }
}

/// Linha dentro de seção agrupada.
class DfGroupedRow extends StatelessWidget {
  const DfGroupedRow({
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    this.showChevron = false,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.iosBody(theme.brightness)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTypography.iosFootnote(theme.brightness),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.secondaryLabel(theme).withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
