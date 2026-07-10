import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Gradientes discretos — iOS prefere superfícies planas.
abstract final class AppGradients {
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.systemBlue,
      AppColors.brandBlueDark,
    ],
  );

  static LinearGradient primaryButton(Brightness brightness) => brand;

  static LinearGradient heroRing(Brightness brightness, Color accent) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [accent, accent.withValues(alpha: 0.6)],
    );
  }

  static LinearGradient heroCardAccent(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.systemBlue.withValues(alpha: 0.18),
          AppColors.iosSecondaryGroupedDark,
        ],
      );
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.systemBlue.withValues(alpha: 0.08),
        AppColors.iosSecondaryGrouped,
      ],
    );
  }

  static LinearGradient surfaceCardTopLight(Brightness brightness) {
    final surface = AppColors.secondaryGrouped(brightness);
    return LinearGradient(colors: [surface, surface]);
  }

  static RadialGradient brandBloom(Brightness brightness) {
    return const RadialGradient(
      colors: [Colors.transparent, Colors.transparent],
    );
  }

  static List<RadialGradient> meshGlows(
    Brightness brightness,
    double animation,
  ) {
    return const [];
  }
}
