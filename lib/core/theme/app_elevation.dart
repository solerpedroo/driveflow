import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Elevação híbrida — hairline iOS + sombra sutil ReuniAI/Mescla.
abstract final class AppElevation {
  static List<BoxShadow> surfaceCard(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
    }
    return [
      BoxShadow(
        color: AppColors.textPrimary.withValues(alpha: 0.04),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
      BoxShadow(
        color: AppColors.brandBlue.withValues(alpha: 0.06),
        blurRadius: 20,
        spreadRadius: -6,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> glassShadow(Brightness brightness) {
    return surfaceCard(brightness);
  }

  static List<BoxShadow> cardShadow(Brightness brightness) {
    return surfaceCard(brightness);
  }

  static List<BoxShadow> brandGlow(Brightness brightness) {
    return [
      BoxShadow(
        color: AppColors.brandBlue.withValues(
          alpha: brightness == Brightness.dark ? 0.38 : 0.26,
        ),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ];
  }

  static List<BoxShadow> navShellShadow(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.40),
          blurRadius: 24,
          offset: const Offset(0, -2),
        ),
      ];
    }
    return [
      BoxShadow(
        color: AppColors.brandBlue.withValues(alpha: 0.12),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static Border rimLight(Brightness brightness) {
    return Border(
      top: BorderSide(
        color: AppColors.separator(ThemeData(brightness: brightness)),
        width: 0.5,
      ),
    );
  }

  static double get tonalButton => 0;
  static double get card => 0;
  static double get sheet => 2;
}
