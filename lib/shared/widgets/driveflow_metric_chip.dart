import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'design_system/df_chip.dart';

/// Chip de métrica — delega para [DfChip] (Design System v2).
@Deprecated('Use DfChip. Será removido em v2.1.')
class DriveFlowMetricChip extends StatelessWidget {
  const DriveFlowMetricChip({
    required this.label,
    required this.value,
    super.key,
    this.accentColor,
    this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final Color? accentColor;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DfChip(
      label: label,
      value: value,
      accentColor: accentColor ?? AppColors.electricTeal,
      icon: icon,
      onTap: onTap,
    );
  }
}
