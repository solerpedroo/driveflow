import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Design tokens centralizados — identidade azul-claro para motoristas.
abstract final class AppColors {
  // Brand — paleta azul-claro (onda 16)
  static const Color skyBlue = Color(0xFF5BA4F5);
  static const Color skyBlueDim = Color(0xFF3B8AE8);
  static const Color skyBlueSoft = Color(0xFF93C5FD);
  static const Color deepNavy = Color(0xFF0A0E17);
  static const Color midnight = Color(0xFF121826);
  static const Color slate = Color(0xFF1E293B);

  /// @deprecated Use [skyBlue]. Mantido para compatibilidade temporária.
  static const Color electricTeal = skyBlue;

  /// @deprecated Use [skyBlueDim]. Mantido para compatibilidade temporária.
  static const Color electricTealDim = skyBlueDim;

  // Semantic
  static const Color profitGreen = Color(0xFF34D399);
  static const Color expenseCoral = Color(0xFFFF6B6B);
  static const Color warningAmber = Color(0xFFFBBF24);
  static const Color infoBlue = Color(0xFF38BDF8);

  // Light mode surfaces
  static const Color lightBackground = Color(0xFFF0F7FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightMuted = Color(0xFFE8F0FE);

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
      Color(0xFFF0F7FF),
      Color(0xFFF5FAFF),
      Color(0xFFEBF4FF),
    ];
  }

  static List<Color> accentGlow(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        skyBlue.withValues(alpha: 0.28),
        skyBlueSoft.withValues(alpha: 0.10),
        Colors.transparent,
      ];
    }
    return [
      skyBlue.withValues(alpha: 0.20),
      skyBlueSoft.withValues(alpha: 0.08),
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
