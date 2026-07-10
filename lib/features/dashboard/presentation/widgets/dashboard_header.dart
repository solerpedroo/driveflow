import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../authentication/domain/entities/user_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../core/utils/df_haptics.dart';

/// Header híbrido — Large Title iOS + eyebrow ReuniAI + avatar Mescla glow.
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
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.brandBlue.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'DASHBOARD',
                      style: AppTypography.labelCaps(brightness),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  greeting,
                  style: AppTypography.iosFootnote(brightness),
                ),
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
          IconButton(
            tooltip: 'Alternar tema',
            onPressed: () {
              DfHaptics.light();
              ref.read(themeModeProvider.notifier).toggle();
            },
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 22,
              color: AppColors.brandBlue,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.brand,
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandBlue.withValues(alpha: 0.30),
                  blurRadius: 10,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 19,
              backgroundColor: isDark
                  ? AppColors.brandNavy
                  : Colors.white.withValues(alpha: 0.95),
              child: Text(
                initial,
                style: AppTypography.iosHeadline(brightness).copyWith(
                  color: AppColors.brandBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
