import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/utils/df_haptics.dart';

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
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animatedProgress;
  late final AnimationController _celebrateController;
  bool _celebrated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DriveFlowMotion.slow,
    );
    _celebrateController = AnimationController(
      vsync: this,
      duration: DriveFlowMotion.normal,
    );
    _animatedProgress = Tween<double>(
      begin: 0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DriveFlowMotion.enter,
    ));
    _controller.forward().whenComplete(_maybeCelebrate);
  }

  void _maybeCelebrate() {
    if (!mounted) return;
    if (widget.progress >= 1.0 && !_celebrated) {
      _celebrated = true;
      DfHaptics.success();
      _celebrateController
        ..reset()
        ..forward();
    }
  }

  @override
  void didUpdateWidget(DfProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      if (widget.progress < 1.0) _celebrated = false;
      _animatedProgress = Tween<double>(
        begin: _animatedProgress.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: DriveFlowMotion.enter,
      ));
      _controller
        ..reset()
        ..forward()
            .whenComplete(_maybeCelebrate);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _celebrateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final track = widget.trackColor ??
        AppColors.mutedSurface(theme).withValues(alpha: 0.5);
    final isComplete = widget.progress >= 1.0;

    return AnimatedBuilder(
      animation: Listenable.merge([_animatedProgress, _celebrateController]),
      builder: (context, child) {
        final celebrateScale = isComplete
            ? 1.0 + (_celebrateController.value * 0.04)
            : 1.0;

        return Transform.scale(
          scale: celebrateScale,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _RingPainter(
                progress: _animatedProgress.value,
                strokeWidth: widget.strokeWidth,
                accentColor: widget.accentColor,
                trackColor: track,
                gradient: AppGradients.heroRing(
                  theme.brightness,
                  widget.accentColor,
                ),
                glowPulse: isComplete ? _celebrateController.value : 0,
              ),
              child: Center(child: child),
            ),
          ),
        );
      },
      child: widget.child,
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
    this.glowPulse = 0,
  });

  final double progress;
  final double strokeWidth;
  final Color accentColor;
  final Color trackColor;
  final Gradient gradient;
  final double glowPulse;

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

    _paintArcTip(canvas, center, radius, sweep);
  }

  void _paintArcTip(Canvas canvas, Offset center, double radius, double sweep) {
    final endAngle = -math.pi / 2 + sweep;
    final tip = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );

    final glowRadius = strokeWidth * (0.5 + glowPulse * 0.35);
    final outerGlow = Paint()
      ..color = accentColor.withValues(alpha: 0.22 + glowPulse * 0.18)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + glowPulse * 6);
    canvas.drawCircle(tip, glowRadius, outerGlow);

    final innerGlow = Paint()
      ..color = accentColor.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(tip, strokeWidth * 0.32, innerGlow);

    final tipPaint = Paint()..color = Colors.white.withValues(alpha: 0.95);
    canvas.drawCircle(tip, strokeWidth * 0.18, tipPaint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.glowPulse != glowPulse;
}
