import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Fundo animado com gradiente ambient + glow — assinatura visual DriveFlow.
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
      duration: const Duration(seconds: 8),
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
    final ambient = AppColors.ambientGradient(brightness);
    final glow = AppColors.accentGlow(brightness);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: ambient,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.2 + t * 0.3, -0.6 + t * 0.2),
                  radius: 1.2,
                  colors: glow,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.8 + t * 0.15, 0.9),
                  radius: 0.9,
                  colors: [
                    AppColors.skyBlue.withValues(alpha: 0.06 + t * 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}
