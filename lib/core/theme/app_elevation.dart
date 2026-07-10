import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Elevação em camadas — profundidade Apple (hairline + soft ambient).
abstract final class AppElevation {
  /// Superfície elevada padrão (cards, sheets leves).
  static List<BoxShadow> surfaceCard(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.45),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];
    }
    return [
      BoxShadow(
        color: const Color(0xFF0B1220).withValues(alpha: 0.04),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
      BoxShadow(
        color: const Color(0xFF0B1220).withValues(alpha: 0.06),
        blurRadius: 16,
        spreadRadius: -2,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: AppColors.brandBlue.withValues(alpha: 0.04),
        blurRadius: 28,
        spreadRadius: -8,
        offset: const Offset(0, 14),
      ),
    ];
  }

  static List<BoxShadow> glassShadow(Brightness brightness) {
    return surfaceCard(brightness);
  }

  static List<BoxShadow> cardShadow(Brightness brightness) {
    return surfaceCard(brightness);
  }

  /// Sombra de CTA — só em botão primário, nunca na nav.
  static List<BoxShadow> brandGlow(Brightness brightness) {
    return [
      BoxShadow(
        color: AppColors.brandBlue.withValues(
          alpha: brightness == Brightness.dark ? 0.28 : 0.18,
        ),
        blurRadius: 14,
        offset: const Offset(0, 5),
      ),
      BoxShadow(
        color: AppColors.brandBlueDeep.withValues(
          alpha: brightness == Brightness.dark ? 0.18 : 0.08,
        ),
        blurRadius: 28,
        spreadRadius: -4,
        offset: const Offset(0, 12),
      ),
    ];
  }

  /// Hero wealth — profundidade densa sem glow neon.
  static List<BoxShadow> heroDepth(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.55),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ];
    }
    return [
      BoxShadow(
        color: AppColors.brandNavy.withValues(alpha: 0.18),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: AppColors.brandBlue.withValues(alpha: 0.12),
        blurRadius: 40,
        spreadRadius: -8,
        offset: const Offset(0, 20),
      ),
    ];
  }

  static List<BoxShadow> navShellShadow(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 20,
          offset: const Offset(0, -2),
        ),
      ];
    }
    return [
      BoxShadow(
        color: const Color(0xFF0B1220).withValues(alpha: 0.06),
        blurRadius: 20,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: const Color(0xFF0B1220).withValues(alpha: 0.03),
        blurRadius: 6,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// Borda hairline completa (não só topo).
  static Border rimLight(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFF0B1220).withValues(alpha: 0.06);
    return Border.all(color: color, width: 0.5);
  }

  static BorderSide hairline(Brightness brightness) {
    return BorderSide(
      color: brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.10)
          : const Color(0xFF0B1220).withValues(alpha: 0.08),
      width: 0.5,
    );
  }

  static double get tonalButton => 0;
  static double get card => 0;
  static double get sheet => 2;
}
