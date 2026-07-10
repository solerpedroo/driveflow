import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

/// Fundo híbrido — shell Mescla + bloom ReuniAI sobre grouped Cupertino.
class DriveFlowGradientBackground extends StatefulWidget {
  const DriveFlowGradientBackground({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<DriveFlowGradientBackground> createState() =>
      _DriveFlowGradientBackgroundState();
}

class _DriveFlowGradientBackgroundState
    extends State<DriveFlowGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final shell = AppColors.shellGradient(brightness);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final mesh = AppGradients.meshGlows(brightness, _controller.value);

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
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}
