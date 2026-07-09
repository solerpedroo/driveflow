import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_motion.dart';

/// Anel de progresso circular — padrão FitCal (calorie ring → profit ring).
class DfProgressRing extends StatefulWidget {
  const DfProgressRing({
    required this.progress,
    required this.child,
    super.key,
    this.size = 200,
    this.strokeWidth = 14,
    this.accentColor = AppColors.skyBlue,
    this.trackColor,
  });

  /// 0.0 – 1.0
  final double progress;
  final Widget child;
  final double size;
  final double strokeWidth;
  final Color accentColor;
  final Color? trackColor;

  @override
  State<DfProgressRing> createState() => _DfProgressRingState();
}

class _DfProgressRingState extends State<DfProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animatedProgress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DriveFlowMotion.slow,
    );
    _animatedProgress = Tween<double>(
      begin: 0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DriveFlowMotion.enter,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(DfProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animatedProgress = Tween<double>(
        begin: _animatedProgress.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: DriveFlowMotion.enter,
      ));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final track = widget.trackColor ??
        AppColors.mutedSurface(theme).withValues(alpha: 0.5);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animatedProgress,
        builder: (context, child) {
          return CustomPaint(
            painter: _RingPainter(
              progress: _animatedProgress.value,
              strokeWidth: widget.strokeWidth,
              accentColor: widget.accentColor,
              trackColor: track,
              gradient: AppGradients.heroRing(
                theme.brightness,
                widget.accentColor,
              ),
            ),
            child: Center(child: child),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.accentColor,
    required this.trackColor,
    required this.gradient,
  });

  final double progress;
  final double strokeWidth;
  final Color accentColor;
  final Color trackColor;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, trackPaint);

    if (progress <= 0) return;

    final sweep = math.pi * 2 * progress;
    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, sweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.accentColor != accentColor;
}
