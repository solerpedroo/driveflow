import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Elevação mínima estilo iOS — separadores em vez de sombras pesadas.
abstract final class AppElevation {
  static List<BoxShadow> surfaceCard(Brightness brightness) {
    return const [];
  }

  static List<BoxShadow> glassShadow(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 12,
          offset: const Offset(0, -2),
        ),
      ];
    }
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, -2),
      ),
    ];
  }

  static List<BoxShadow> cardShadow(Brightness brightness) {
    return surfaceCard(brightness);
  }

  static List<BoxShadow> brandGlow(Brightness brightness) {
    return const [];
  }

  static List<BoxShadow> navShellShadow(Brightness brightness) {
    return glassShadow(brightness);
  }

  static Border rimLight(Brightness brightness) {
    return Border(
      top: BorderSide(
        color: AppColors.separator(
          ThemeData(brightness: brightness),
        ),
        width: 0.5,
      ),
    );
  }

  static double get tonalButton => 0;
  static double get card => 0;
  static double get sheet => 2;
}
