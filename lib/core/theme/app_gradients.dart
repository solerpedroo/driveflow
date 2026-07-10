import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Gradientes híbridos — ReuniAI brand + Mescla hero + base Cupertino plana.
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

  /// Hero wealth — Mescla indigo + ReuniAI blue.
  static const LinearGradient heroWealth = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.brandBlue, AppColors.mesclaIndigo],
  );

  static LinearGradient primaryButton(Brightness brightness) => brand;

  static LinearGradient heroRing(Brightness brightness, Color accent) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [accent, accent.withValues(alpha: 0.55)],
    );
  }

  /// ReuniAI — cartão com tint brand/6% sobre grouped.
  static LinearGradient heroCardAccent(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.brandBlue.withValues(alpha: 0.22),
          AppColors.iosSecondaryGroupedDark,
          AppColors.iosSecondaryGroupedDark,
        ],
      );
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.brandBlue.withValues(alpha: 0.07),
        AppColors.iosSecondaryGrouped,
        AppColors.iosSecondaryGrouped,
      ],
    );
  }

  static LinearGradient surfaceCardTopLight(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.slate.withValues(alpha: 0.9),
          AppColors.iosSecondaryGroupedDark,
        ],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.iosSecondaryGrouped, AppColors.lightMuted],
    );
  }

  static RadialGradient brandBloom(Brightness brightness) {
    final alpha = brightness == Brightness.dark ? 0.12 : 0.07;
    return RadialGradient(
      center: const Alignment(0, -1.1),
      radius: 1.2,
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
          center: Alignment(0.12 + t * 0.18, -0.55 + t * 0.1),
          radius: 1.0,
          colors: [
            AppColors.brandBlue.withValues(alpha: 0.16),
            Colors.transparent,
          ],
        ),
        RadialGradient(
          center: Alignment(-0.7 + t * 0.08, 0.9),
          radius: 0.8,
          colors: [
            AppColors.mesclaIndigo.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ),
      ];
    }
    return [
      brandBloom(brightness),
      RadialGradient(
        center: Alignment(-0.6 + t * 0.1, 0.92),
        radius: 0.85,
        colors: [
          AppColors.brandGlow.withValues(alpha: 0.14),
          Colors.transparent,
        ],
      ),
    ];
  }
}
