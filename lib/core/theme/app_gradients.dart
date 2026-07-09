import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Gradientes premium — referência FitCal / FitFolio (mesh + hero fills).
abstract final class AppGradients {
  static LinearGradient primaryButton(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6BB4FF), Color(0xFF3B8AE8)],
      );
    }
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF5BA4F5), Color(0xFF2E7FD9)],
    );
  }

  static LinearGradient heroRing(Brightness brightness, Color accent) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        accent,
        accent.withValues(alpha: 0.55),
      ],
    );
  }

  static LinearGradient heroCardAccent(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.skyBlue.withValues(alpha: 0.22),
          AppColors.skyBlueSoft.withValues(alpha: 0.06),
        ],
      );
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.skyBlue.withValues(alpha: 0.14),
        Colors.white.withValues(alpha: 0.0),
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
          center: Alignment(0.15 + t * 0.25, -0.55 + t * 0.15),
          radius: 1.1,
          colors: [
            AppColors.skyBlue.withValues(alpha: 0.32),
            Colors.transparent,
          ],
        ),
        RadialGradient(
          center: Alignment(-0.75 + t * 0.1, 0.85),
          radius: 0.85,
          colors: [
            const Color(0xFF818CF8).withValues(alpha: 0.14),
            Colors.transparent,
          ],
        ),
        RadialGradient(
          center: Alignment(0.9 - t * 0.12, 0.1),
          radius: 0.7,
          colors: [
            AppColors.profitGreen.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ),
      ];
    }
    return [
      RadialGradient(
        center: Alignment(0.2 + t * 0.2, -0.5 + t * 0.18),
        radius: 1.15,
        colors: [
          AppColors.skyBlue.withValues(alpha: 0.22),
          Colors.transparent,
        ],
      ),
      RadialGradient(
        center: Alignment(-0.7 + t * 0.12, 0.9),
        radius: 0.95,
        colors: [
          AppColors.skyBlueSoft.withValues(alpha: 0.16),
          Colors.transparent,
        ],
      ),
      RadialGradient(
        center: Alignment(0.85, 0.15),
        radius: 0.65,
        colors: [
          const Color(0xFFE0F2FE).withValues(alpha: 0.9),
          Colors.transparent,
        ],
      ),
    ];
  }
}
