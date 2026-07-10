import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Gradientes premium — marca azul com profundidade editorial.
abstract final class AppGradients {
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A6FFF),
      AppColors.brandBlue,
      AppColors.brandBlueDark,
    ],
    stops: [0.0, 0.55, 1.0],
  );

  static LinearGradient primaryButton(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3B82F6), AppColors.brandBlue, AppColors.brandBlueDark],
      );
    }
    return brand;
  }

  static LinearGradient heroRing(Brightness brightness, Color accent) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [accent, accent.withValues(alpha: 0.55)],
    );
  }

  static LinearGradient heroCardAccent(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.brandBlue.withValues(alpha: 0.28),
          AppColors.brandBlueDeep.withValues(alpha: 0.12),
        ],
      );
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.brandBlue.withValues(alpha: 0.08),
        AppColors.lightSurface,
        AppColors.lightSurface,
      ],
    );
  }

  static LinearGradient surfaceCardTopLight(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.slate.withValues(alpha: 0.85),
          AppColors.midnight,
        ],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.lightSurface, AppColors.lightMuted],
    );
  }

  static RadialGradient brandBloom(Brightness brightness) {
    final alpha = brightness == Brightness.dark ? 0.14 : 0.09;
    return RadialGradient(
      center: const Alignment(0, -1.15),
      radius: 1.25,
      colors: [
        AppColors.brandBlue.withValues(alpha: alpha),
        Colors.transparent,
      ],
    );
  }

  static List<RadialGradient> meshGlows(
    Brightness brightness,
    double animation,
  ) {
    final t = animation;
    if (brightness == Brightness.dark) {
      return [
        RadialGradient(
          center: Alignment(0.1 + t * 0.2, -0.6 + t * 0.12),
          radius: 1.1,
          colors: [
            AppColors.brandBlue.withValues(alpha: 0.20),
            Colors.transparent,
          ],
        ),
        RadialGradient(
          center: Alignment(-0.8 + t * 0.1, 0.85),
          radius: 0.9,
          colors: [
            AppColors.brandGlow.withValues(alpha: 0.06),
            Colors.transparent,
          ],
        ),
      ];
    }
    return [
      brandBloom(brightness),
      RadialGradient(
        center: Alignment(-0.65 + t * 0.1, 0.95),
        radius: 0.85,
        colors: [
          AppColors.brandGlow.withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ),
    ];
  }
}
