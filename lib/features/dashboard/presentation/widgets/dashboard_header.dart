import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../authentication/domain/entities/user_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../core/utils/df_haptics.dart';

/// Cabeçalho premium — avatar com anel luminoso.
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
                Text(
                  '$greeting,',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                  ),
                ),
                Text(
                  name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
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
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.skyBlue,
                  AppColors.skyBlueSoft,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.skyBlue.withValues(alpha: 0.35),
                  blurRadius: 12,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.skyBlue.withValues(alpha: 0.15),
              child: Text(
                initial,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.skyBlue,
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
