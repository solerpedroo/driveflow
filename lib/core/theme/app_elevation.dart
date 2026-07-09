import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Sombras glass e elevação Material 3.
abstract final class AppElevation {
  static List<BoxShadow> glassShadow(Brightness brightness) {
    if (brightness == Brightness.dark) return const [];
    return [
      BoxShadow(
        color: AppColors.deepNavy.withValues(alpha: 0.06),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> cardShadow(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
    }
    return glassShadow(brightness);
  }

  static double get tonalButton => 0;
  static double get card => 1;
  static double get sheet => 3;
}
