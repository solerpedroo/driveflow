import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Fundo agrupado iOS — canvas plano sem mesh animado.
class DriveFlowGradientBackground extends StatelessWidget {
  const DriveFlowGradientBackground({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bg = AppColors.groupedBackground(brightness);

    return ColoredBox(
      color: bg,
      child: child,
    );
  }
}
