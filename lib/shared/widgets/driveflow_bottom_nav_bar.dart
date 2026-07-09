import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';

const Duration kDriveFlowTabSwitchDuration = DriveFlowMotion.normal;

/// Bottom navigation premium — cápsula flutuante com animação suave.
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

  static const double _itemTrackHeight = 56;
  static const double _chipVerticalMargin = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final shell = AppColors.bottomNavBarShell(theme);
    final isDark = theme.brightness == Brightness.dark;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.30)
        : AppColors.skyBlue.withValues(alpha: 0.18);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        decoration: BoxDecoration(
          color: shell,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isDark
                ? AppColors.glassBorder
                : AppColors.glassBorderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
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
                      trackHeight: _itemTrackHeight,
                      chipVertMargin: _chipVerticalMargin,
                      activeColor: primary,
                      inactiveColor: AppColors.bottomNavInactive(theme),
                      onTap: () => onItemTap(i),
                    ),
                  ),
              ],
            ),
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
    required this.trackHeight,
    required this.chipVertMargin,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final double trackHeight;
  final double chipVertMargin;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final contentColor = isActive ? Colors.white : inactiveColor;

    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: contentColor,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          fontSize: 10,
        );

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedScale(
          scale: isActive ? 1.05 : 1.0,
          duration: DriveFlowMotion.fast,
          child: Icon(icon, color: contentColor, size: 22),
        ),
        const SizedBox(height: 3),
        AnimatedDefaultTextStyle(
          duration: DriveFlowMotion.fast,
          style: textStyle!,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    final chipHeight = trackHeight - 2 * chipVertMargin;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Center(
          child: AnimatedContainer(
            duration: DriveFlowMotion.fast,
            curve: DriveFlowMotion.standard,
            constraints: BoxConstraints(
              minWidth: isActive ? 72 : 48,
              minHeight: chipHeight,
              maxHeight: chipHeight,
            ),
            decoration: isActive
                ? BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  )
                : null,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 12 : 4,
              ),
              child: Center(child: column),
            ),
          ),
        ),
      ),
    );
  }
}
