import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Estado vazio padronizado do Design System v2.
class DfEmptyState extends StatelessWidget {
  const DfEmptyState({
    required this.title,
    super.key,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: subtitle == null ? title : '$title. $subtitle',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 56,
                color: AppColors.secondaryLabel(theme).withValues(alpha: 0.6),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
