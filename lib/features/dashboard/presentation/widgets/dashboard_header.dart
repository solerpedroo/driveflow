import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../authentication/domain/entities/user_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../shared/widgets/driveflow_brand_logo.dart';

/// Cabeçalho do dashboard com logo, usuário e toggle de tema.
class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({required this.user, super.key});

  final UserEntity? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.screenTop,
        AppSpacing.screenHorizontal,
        0,
      ),
      child: Row(
        children: [
          const Expanded(child: DriveFlowBrandLogo(size: LogoSize.medium)),
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Chip(
                avatar: CircleAvatar(
                  backgroundColor:
                      AppColors.electricTeal.withValues(alpha: 0.2),
                  child: Text(
                    user!.displayName.characters.first.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.electricTeal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                label: Text(user!.displayName),
              ),
            ),
          Semantics(
            button: true,
            label: 'Alternar tema',
            child: IconButton.filledTonal(
              tooltip: 'Alternar tema',
              onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
