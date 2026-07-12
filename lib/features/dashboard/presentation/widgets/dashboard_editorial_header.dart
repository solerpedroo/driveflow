import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/design_system/df_header_row.dart';
import '../../../../shared/widgets/design_system/df_hero_wealth_card.dart';
import '../../../authentication/presentation/widgets/auth_editorial_chrome.dart';

/// Cabeçalho editorial da Início — mesmo ritmo das telas de auth.
class DashboardEditorialHeader extends StatelessWidget {
  const DashboardEditorialHeader({
    required this.greeting,
    required this.subtitle,
    required this.hidden,
    required this.onToggleVisibility,
    super.key,
  });

  final String greeting;
  final String subtitle;
  final bool hidden;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DfHeaderRow(
          trailing: DfValueVisibilityButton(
            hidden: hidden,
            onToggle: onToggleVisibility,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          greeting,
          style: AppTypography.iosBody(brightness).copyWith(
            color: AppColors.secondaryLabel(theme),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Seu lucro',
          style: AppTypography.iosLargeTitle(brightness).copyWith(
            fontSize: 34,
            height: 1.05,
            letterSpacing: -1.1,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const AuthEditorialRule(),
        const SizedBox(height: AppSpacing.md),
        Text(
          subtitle,
          style: AppTypography.iosBody(brightness).copyWith(
            color: AppColors.secondaryLabel(theme),
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
