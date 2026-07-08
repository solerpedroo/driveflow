import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Estado vazio ilustrado para listas sem dados.
class DriveFlowEmptyState extends StatelessWidget {
  const DriveFlowEmptyState({
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: title,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 56,
                color: AppColors.secondaryLabel(theme).withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
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
