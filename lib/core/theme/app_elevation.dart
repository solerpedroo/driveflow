import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Sombras premium — multi-camada estilo surface-card (ReuniAI).
abstract final class AppElevation {
  static List<BoxShadow> surfaceCard(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: AppColors.brandBlue.withValues(alpha: 0.10),
          blurRadius: 36,
          spreadRadius: -12,
          offset: const Offset(0, 16),
        ),
      ];
    }
    return [
      BoxShadow(
        color: AppColors.textPrimary.withValues(alpha: 0.05),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
      BoxShadow(
        color: AppColors.textPrimary.withValues(alpha: 0.10),
        blurRadius: 10,
        spreadRadius: -5,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: AppColors.textPrimary.withValues(alpha: 0.20),
        blurRadius: 36,
        spreadRadius: -22,
        offset: const Offset(0, 16),
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
          alpha: brightness == Brightness.dark ? 0.45 : 0.28,
        ),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> navShellShadow(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.50),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: AppColors.brandBlue.withValues(alpha: 0.14),
          blurRadius: 24,
          spreadRadius: -4,
        ),
      ];
    }
    return [
      BoxShadow(
        color: AppColors.brandBlue.withValues(alpha: 0.16),
        blurRadius: 28,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: AppColors.textPrimary.withValues(alpha: 0.06),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static Border rimLight(Brightness brightness) {
    return Border.all(
      color: brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.10)
          : Colors.white.withValues(alpha: 0.70),
    );
  }

  static double get tonalButton => 0;
  static double get card => 1;
  static double get sheet => 3;
}
