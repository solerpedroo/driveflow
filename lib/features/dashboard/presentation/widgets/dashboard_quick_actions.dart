import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/df_haptics.dart';

class DashboardQuickAction {
  const DashboardQuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// Ações rápidas minimalistas — linha única de ícones.
class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({required this.actions, super.key});

  final List<DashboardQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(child: _ActionCell(action: actions[i])),
        ],
      ],
    );
  }
}

class _ActionCell extends StatelessWidget {
  const _ActionCell({required this.action});

  final DashboardQuickAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          DfHaptics.light();
          action.onTap();
        },
        borderRadius: AppRadius.lgAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandBlue.withValues(alpha: 0.10),
                ),
                child: Icon(
                  action.icon,
                  size: 20,
                  color: AppColors.brandBlue,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.iosCaption(brightness).copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
