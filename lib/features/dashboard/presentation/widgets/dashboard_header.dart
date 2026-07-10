import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../authentication/domain/entities/user_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../core/utils/df_haptics.dart';

/// Cabeçalho Large Title estilo iOS.
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
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppTypography.iosFootnote(brightness),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: AppTypography.iosLargeTitle(brightness),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Semantics(
            button: true,
            label: 'Alternar tema',
            child: IconButton(
              tooltip: 'Alternar tema',
              onPressed: () {
                DfHaptics.light();
                ref.read(themeModeProvider.notifier).toggle();
              },
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: 22,
                color: AppColors.systemBlue,
              ),
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.systemBlue.withValues(alpha: 0.12),
            child: Text(
              initial,
              style: AppTypography.iosHeadline(brightness).copyWith(
                color: AppColors.systemBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
