import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_elevation.dart';
import '../../core/theme/app_motion.dart';
import '../../core/utils/df_haptics.dart';

const Duration kDriveFlowTabSwitchDuration = DriveFlowMotion.normal;

/// Tab bar estilo Cupertino — blur, ícones, azul system no ativo.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final active = AppColors.systemBlue;
    final inactive = AppColors.bottomNavInactive(theme);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: AppElevation.rimLight(brightness),
        boxShadow: AppElevation.navShellShadow(brightness),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: ColoredBox(
            color: AppColors.bottomNavBarShell(theme),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 50,
                child: Row(
                  children: [
                    for (var i = 0; i < itemCount; i++)
                      Expanded(
                        child: _TabItem(
                          icon: _icons[i],
                          label: _labels[i],
                          isActive: selectedIndex == i,
                          activeColor: active,
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
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.12,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
