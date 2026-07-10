import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Gradientes de profundidade — navy → blue, sem indigo/roxo.
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

  /// Hero principal — profundidade Wallet (navy → brand).
  static const LinearGradient heroWealth = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0B1F3A),
      AppColors.brandBlueDeep,
      AppColors.brandBlue,
    ],
    stops: [0.0, 0.45, 1.0],
  );

  static LinearGradient primaryButton(Brightness brightness) => brand;

  static LinearGradient heroRing(Brightness brightness, Color accent) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [accent, accent.withValues(alpha: 0.55)],
    );
  }

  /// Cartão hero suave — tint brand sem “card marketing”.
  static LinearGradient heroCardAccent(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.brandBlue.withValues(alpha: 0.16),
          AppColors.iosSecondaryGroupedDark,
          AppColors.iosSecondaryGroupedDark,
        ],
      );
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.brandBlue.withValues(alpha: 0.05),
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
          AppColors.slate.withValues(alpha: 0.95),
          AppColors.iosSecondaryGroupedDark,
        ],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFFFFF), Color(0xFFF7F9FC)],
    );
  }

  static RadialGradient brandBloom(Brightness brightness) {
    final alpha = brightness == Brightness.dark ? 0.10 : 0.055;
    return RadialGradient(
      center: const Alignment(0.15, -0.95),
      radius: 1.15,
      colors: [
        AppColors.brandBlue.withValues(alpha: alpha),
        Colors.transparent,
      ],
    );
  }

  /// Blooms estáticos de profundidade (sem animação).
  static List<RadialGradient> meshGlows(
    Brightness brightness,
    double animation,
  ) {
    // `animation` mantido na assinatura por compatibilidade; ignorado.
    if (brightness == Brightness.dark) {
      return [
        RadialGradient(
          center: const Alignment(0.2, -0.7),
          radius: 1.05,
          colors: [
            AppColors.brandBlue.withValues(alpha: 0.12),
            Colors.transparent,
          ],
        ),
        RadialGradient(
          center: const Alignment(-0.75, 0.85),
          radius: 0.9,
          colors: [
            AppColors.brandBlueDeep.withValues(alpha: 0.10),
            Colors.transparent,
          ],
        ),
      ];
    }
    return [
      brandBloom(brightness),
      RadialGradient(
        center: const Alignment(-0.65, 0.95),
        radius: 0.9,
        colors: [
          AppColors.brandGlow.withValues(alpha: 0.10),
          Colors.transparent,
        ],
      ),
    ];
  }
}
