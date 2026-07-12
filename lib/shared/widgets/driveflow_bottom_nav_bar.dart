import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import 'design_system/df_bottom_nav_bar.dart';

export 'design_system/df_bottom_nav_bar.dart' show DfBottomNavBar, DfBottomNavItem;

const Duration kDriveFlowTabSwitchDuration = DriveFlowMotion.normal;

/// Tab bar DriveFlow — liquid glass via [DfBottomNavBar].
class DriveFlowBottomNavBar extends StatelessWidget {
  const DriveFlowBottomNavBar({
    required this.selectedIndex,
    required this.onItemTap,
    super.key,
  });

  static const int itemCount = 5;

  final int selectedIndex;
  final ValueChanged<int> onItemTap;

  static const List<DfBottomNavItem> _items = [
    DfBottomNavItem(
      icon: Icons.home_rounded,
      label: 'Início',
      semanticKey: ValueKey('driveflow_nav_inicio'),
    ),
    DfBottomNavItem(
      icon: Icons.payments_rounded,
      label: 'Ganhos',
      semanticKey: ValueKey('driveflow_nav_ganhos'),
    ),
    DfBottomNavItem(
      icon: Icons.receipt_long_rounded,
      label: 'Despesas',
      semanticKey: ValueKey('driveflow_nav_despesas'),
    ),
    DfBottomNavItem(
      icon: Icons.bar_chart_rounded,
      label: 'Relatórios',
      semanticKey: ValueKey('driveflow_nav_relatorios'),
    ),
    DfBottomNavItem(
      icon: Icons.person_rounded,
      label: 'Perfil',
      semanticKey: ValueKey('driveflow_nav_perfil'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DfBottomNavBar(
      items: _items,
      selectedIndex: selectedIndex,
      onItemTap: onItemTap,
    );
  }
}
