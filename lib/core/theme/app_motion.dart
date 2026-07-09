import 'package:flutter/material.dart';

/// Durações e curvas de animação consistentes.
abstract final class DriveFlowMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration pulse = Duration(milliseconds: 2200);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;

  static Animation<double> fadeIn(AnimationController controller) {
    return CurvedAnimation(parent: controller, curve: enter);
  }
}
