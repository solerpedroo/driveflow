import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Design tokens centralizados — identidade "cockpit noturno" para motoristas.
abstract final class AppColors {
  // Brand
  static const Color electricTeal = Color(0xFF00E5B8);
  static const Color electricTealDim = Color(0xFF00B894);
  static const Color deepNavy = Color(0xFF0A0E17);
  static const Color midnight = Color(0xFF121826);
  static const Color slate = Color(0xFF1E293B);

  // Semantic
  static const Color profitGreen = Color(0xFF34D399);
  static const Color expenseCoral = Color(0xFFFF6B6B);
  static const Color warningAmber = Color(0xFFFBBF24);
  static const Color infoBlue = Color(0xFF38BDF8);

  // Light mode surfaces
  static const Color lightBackground = Color(0xFFF4F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightMuted = Color(0xFFE8EDF5);

  // Text
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Borders & glass
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassBorderLight = Color(0x1A0A0E17);

  static const SystemUiOverlayStyle darkOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: deepNavy,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static const SystemUiOverlayStyle lightOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: lightBackground,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static List<Color> ambientGradient(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const [
        Color(0xFF0A0E17),
        Color(0xFF121826),
        Color(0xFF0F172A),
      ];
    }
    return const [
      Color(0xFFF0FDF9),
      Color(0xFFF4F7FB),
      Color(0xFFEFF6FF),
    ];
  }

  static List<Color> accentGlow(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        electricTeal.withValues(alpha: 0.25),
        const Color(0xFF6366F1).withValues(alpha: 0.12),
        Colors.transparent,
      ];
    }
    return [
      electricTeal.withValues(alpha: 0.18),
      const Color(0xFF818CF8).withValues(alpha: 0.08),
      Colors.transparent,
    ];
  }

  static Color cardSurface(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return slate.withValues(alpha: 0.65);
    }
    return lightSurface;
  }

  static Color mutedSurface(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return midnight;
    }
    return lightMuted;
  }

  static Color secondaryLabel(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return textSecondary;
    }
    return textSecondaryLight;
  }

  static Color bottomNavInactive(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return textSecondary;
    }
    return textSecondaryLight;
  }

  static Color bottomNavBarShell(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return slate.withValues(alpha: 0.92);
    }
    return lightSurface;
  }
}
