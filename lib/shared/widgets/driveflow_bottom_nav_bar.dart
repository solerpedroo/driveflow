import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/df_haptics.dart';
import 'design_system/df_glass_surface.dart';

const Duration kDriveFlowTabSwitchDuration = DriveFlowMotion.normal;

/// Tab bar glass — active tint quieto (sem gradient glow).
class DriveFlowBottomNavBar extends StatelessWidget {
  const DriveFlowBottomNavBar({
    required this.selectedIndex,
    required this.onItemTap,
    super.key,
  });

  static const int itemCount = 5;

  final int selectedIndex;
  final ValueChanged<int> onItemTap;

  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.payments_rounded,
    Icons.receipt_long_rounded,
    Icons.bar_chart_rounded,
    Icons.person_rounded,
  ];

  static const List<String> _labels = [
    'Início',
    'Ganhos',
    'Despesas',
    'Relatórios',
    'Perfil',
  ];

  static const double _itemTrackHeight = 52;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inactive = AppColors.bottomNavInactive(theme);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: DfGlassSurface(
        borderRadius: BorderRadius.circular(28),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: SizedBox(
          height: _itemTrackHeight,
          child: Row(
            children: [
              for (var i = 0; i < itemCount; i++)
                Expanded(
                  child: _NavItem(
                    icon: _icons[i],
                    label: _labels[i],
                    isActive: selectedIndex == i,
                    inactiveColor: inactive,
                    onTap: () {
                      DfHaptics.selection();
                      onItemTap(i);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.inactiveColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final contentColor = isActive
        ? AppColors.navActiveForeground(brightness)
        : inactiveColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedContainer(
          duration: DriveFlowMotion.fast,
          curve: Curves.easeOutCubic,
          constraints: BoxConstraints(
            minWidth: isActive ? 64 : 44,
            minHeight: 40,
          ),
          decoration: isActive
              ? BoxDecoration(
                  color: AppColors.navActiveFill(brightness),
                  borderRadius: BorderRadius.circular(20),
                )
              : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isActive ? 8 : 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: contentColor),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTypography.iosCaption(brightness).copyWith(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: contentColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
