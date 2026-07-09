import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'df_button.dart';

enum DfEmptyStateVariant { standard, illustrated }

/// Estado vazio premium — orb gradiente + CTA narrativo.
class DfEmptyState extends StatelessWidget {
  const DfEmptyState({
    required this.title,
    super.key,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.variant = DfEmptyStateVariant.standard,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final DfEmptyStateVariant variant;

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
              if (variant == DfEmptyStateVariant.illustrated)
                _IllustratedOrb(icon: icon)
              else
                Icon(
                  icon,
                  size: 56,
                  color: AppColors.secondaryLabel(theme).withValues(alpha: 0.6),
                ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                    height: 1.45,
                  ),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.lg),
                DfButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  variant: DfButtonVariant.gradient,
                  expand: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IllustratedOrb extends StatelessWidget {
  const _IllustratedOrb({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.skyBlue.withValues(alpha: 0.28),
            AppColors.skyBlue.withValues(alpha: 0.04),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.skyBlue.withValues(alpha: 0.22),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, size: 40, color: AppColors.skyBlue),
    );
  }
}
