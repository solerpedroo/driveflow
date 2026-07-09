import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Card de boas-vindas do cockpit.
class DashboardCockpitCard extends StatelessWidget {
  const DashboardCockpitCard({
    required this.displayName,
    required this.vehicleLine,
    required this.pulseAnimation,
    super.key,
  });

  final String displayName;
  final String vehicleLine;
  final double pulseAnimation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PulseDot(animation: pulseAnimation),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'COCKPIT ATIVO',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.electricTeal,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Olá, $displayName!', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            vehicleLine,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryLabel(theme),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot({required this.animation});

  final double animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.electricTeal.withValues(alpha: 0.5 + animation * 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricTeal
                .withValues(alpha: 0.35 + animation * 0.25),
            blurRadius: 8 + animation * 6,
          ),
        ],
      ),
    );
  }
}
