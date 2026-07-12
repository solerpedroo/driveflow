import 'package:flutter/material.dart';

import '../../../../core/constants/driver_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Seletor de perfil operacional — motorista de app vs taxista.
class DriverTypePicker extends StatelessWidget {
  const DriverTypePicker({
    required this.selected,
    required this.onChanged,
    super.key,
    this.showHeader = true,
  });

  final DriverType selected;
  final ValueChanged<DriverType> onChanged;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeader) ...[
          Text(
            'Como você trabalha?',
            style: AppTypography.iosHeadline(brightness),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Personalizamos o painel, os ganhos e o onboarding para sua rotina.',
            style: AppTypography.iosFootnote(brightness),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        for (final type in DriverType.values) ...[
          _DriverTypeCard(
            type: type,
            selected: selected == type,
            onTap: () => onChanged(type),
          ),
          if (type != DriverType.values.last)
            const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _DriverTypeCard extends StatelessWidget {
  const _DriverTypeCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final DriverType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: DriveFlowMotion.fast,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: selected
                ? AppColors.brandBlue.withValues(alpha: 0.10)
                : AppColors.secondaryGrouped(brightness),
            border: Border.all(
              color: selected
                  ? AppColors.brandBlue.withValues(alpha: 0.45)
                  : AppElevation.hairline(brightness).color,
              width: selected ? 1.5 : 0.5,
            ),
            boxShadow: selected ? AppElevation.surfaceCard(brightness) : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: selected
                      ? AppColors.brandBlue.withValues(alpha: 0.16)
                      : AppColors.mutedSurface(theme),
                ),
                child: Icon(
                  type.icon,
                  color: selected
                      ? AppColors.brandBlue
                      : AppColors.secondaryLabel(theme),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.isTaxi
                          ? 'Registro manual de corridas, sem integrações.'
                          : 'Uber, 99, InDrive e atualização automática.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryLabel(theme),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: DriveFlowMotion.fast,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.brandBlue
                        : AppColors.secondaryLabel(theme),
                    width: selected ? 6 : 1.5,
                  ),
                  color: selected ? Colors.white : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
