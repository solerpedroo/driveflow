import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Sombras glass, rim light e elevação premium.
abstract final class AppElevation {
  static List<BoxShadow> glassShadow(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        BoxShadow(
          color: AppColors.skyBlue.withValues(alpha: 0.08),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
    }
    return [
      BoxShadow(
        color: AppColors.deepNavy.withValues(alpha: 0.06),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: AppColors.skyBlue.withValues(alpha: 0.06),
        blurRadius: 32,
        offset: const Offset(0, 16),
      ),
    ];
  }

  static List<BoxShadow> cardShadow(Brightness brightness) {
    return glassShadow(brightness);
  }

  static List<BoxShadow> navShellShadow(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.45),
          blurRadius: 32,
          offset: const Offset(0, -4),
        ),
        BoxShadow(
          color: AppColors.skyBlue.withValues(alpha: 0.12),
          blurRadius: 24,
          spreadRadius: -4,
        ),
      ];
    }
    return [
      BoxShadow(
        color: AppColors.skyBlue.withValues(alpha: 0.14),
        blurRadius: 28,
        offset: const Offset(0, 10),
      ),
    ];
  }

  static Border rimLight(Brightness brightness) {
    return Border.all(
      color: brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.65),
    );
  }

  static double get tonalButton => 0;
  static double get card => 1;
  static double get sheet => 3;
}
