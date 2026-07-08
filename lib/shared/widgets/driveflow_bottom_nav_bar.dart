import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

const Duration kDriveFlowTabSwitchDuration = Duration(milliseconds: 280);

/// Bottom navigation estilo cápsula flutuante — identidade DriveFlow.
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
    Icons.dashboard_rounded,
    Icons.payments_outlined,
    Icons.receipt_long_outlined,
    Icons.bar_chart_rounded,
    Icons.person_outline,
  ];

  static const List<String> _labels = [
    'INÍCIO',
    'GANHOS',
    'DESPESAS',
    'RELATÓRIOS',
    'PERFIL',
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
        ? Colors.black.withValues(alpha: 0.24)
        : primary.withValues(alpha: 0.2);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: shell,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          fontSize: 9.5,
        );

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: contentColor, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: textStyle,
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
          child: isActive
              ? ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 72,
                    minHeight: chipHeight,
                    maxHeight: chipHeight,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Center(child: column),
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(vertical: chipVertMargin),
                  child: column,
                ),
        ),
      ),
    );
  }
}
