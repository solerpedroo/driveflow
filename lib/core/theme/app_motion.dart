import 'package:flutter/material.dart';

/// Durações e curvas de animação consistentes — tier outlier.
abstract final class DriveFlowMotion {
  static const Duration micro = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration chart = Duration(milliseconds: 900);
  static const Duration pulse = Duration(milliseconds: 2200);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve spring = Curves.easeOutBack;
  static const Curve snap = Curves.easeOutQuart;

  static Animation<double> fadeIn(AnimationController controller) {
    return CurvedAnimation(parent: controller, curve: enter);
  }

  static Animation<double> springIn(AnimationController controller) {
    return CurvedAnimation(parent: controller, curve: spring);
  }
}
