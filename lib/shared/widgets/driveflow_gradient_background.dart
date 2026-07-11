import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

/// Fundo ambient — profundidade estática em camadas (sem mesh animado).
class DriveFlowGradientBackground extends StatelessWidget {
  const DriveFlowGradientBackground({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final shell = AppColors.shellGradient(brightness);
    final mesh = AppGradients.meshGlows(brightness, 0);

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: shell,
            ),
          ),
        ),
        for (final glow in mesh)
          DecoratedBox(decoration: BoxDecoration(gradient: glow)),
        child,
      ],
    );
  }
}
