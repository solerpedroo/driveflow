import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../authentication/domain/entities/user_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../core/utils/df_haptics.dart';

/// Cabeçalho premium — saudação editorial + avatar com anel de marca.
class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({required this.user, super.key});

  final UserEntity? user;

  static String _greetingForHour(int hour) {
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hour = DateTime.now().hour;
    final greeting = _greetingForHour(hour);
    final name = user?.displayName ?? 'motorista';
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : 'D';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.screenTop,
        AppSpacing.screenHorizontal,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.brandBlue.withValues(alpha: 0.50),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'DASHBOARD',
                      style: AppTypography.labelCaps(theme.brightness),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$greeting, $name',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Semantics(
            button: true,
            label: 'Alternar tema',
            child: IconButton.filledTonal(
              tooltip: 'Alternar tema',
              onPressed: () {
                DfHaptics.light();
                ref.read(themeModeProvider.notifier).toggle();
              },
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: 20,
              ),
              style: IconButton.styleFrom(
                minimumSize: const Size(40, 40),
                backgroundColor: AppColors.mutedSurface(theme),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.brandBlue, AppColors.brandBlueDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandBlue.withValues(alpha: 0.35),
                  blurRadius: 14,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: isDark
                  ? AppColors.brandNavy
                  : Colors.white.withValues(alpha: 0.95),
              child: Text(
                initial,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.brandBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
