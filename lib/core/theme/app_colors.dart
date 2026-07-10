import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Design tokens — paleta premium azul (referência ReuniAI + Mescla).
abstract final class AppColors {
  // Brand — azul premium
  static const Color brandBlue = Color(0xFF0064F5);
  static const Color brandBlueDark = Color(0xFF0047B8);
  static const Color brandBlueDeep = Color(0xFF002D6E);
  static const Color brandGlow = Color(0xFFB8D4FF);
  static const Color brandNavy = Color(0xFF0A192F);

  /// Aliases legados — propagam a nova paleta sem refatorar telas.
  static const Color skyBlue = brandBlue;
  static const Color skyBlueDim = brandBlueDark;
  static const Color skyBlueSoft = brandGlow;

  static const Color deepNavy = brandNavy;
  static const Color midnight = Color(0xFF0F1419);
  static const Color slate = Color(0xFF1A2332);

  /// @deprecated Use [brandBlue].
  static const Color electricTeal = brandBlue;

  /// @deprecated Use [brandBlueDark].
  static const Color electricTealDim = brandBlueDark;

  // Semantic
  static const Color profitGreen = Color(0xFF10B981);
  static const Color expenseCoral = Color(0xFFEF4444);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color infoBlue = Color(0xFF38BDF8);

  // Light mode surfaces — canvas neutro premium
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightMuted = Color(0xFFF5F5F5);
  static const Color lightBorder = Color(0xFFEBEBEB);

  // Text
  static const Color textPrimary = Color(0xFF252525);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textSecondaryLight = Color(0xFF737373);

  // Borders & glass
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassBorderLight = Color(0x1A0A192F);

  static const SystemUiOverlayStyle darkOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: brandNavy,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static const SystemUiOverlayStyle lightOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: lightBackground,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static List<Color> shellGradient(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const [Color(0xFF0F1419), Color(0xFF0A192F)];
    }
    return const [Color(0xFFF8FAFC), Color(0xFFFAFAFA), Color(0xFFFFFFFF)];
  }

  static List<Color> ambientGradient(Brightness brightness) {
    return shellGradient(brightness);
  }

  static List<Color> accentGlow(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        brandBlue.withValues(alpha: 0.22),
        brandGlow.withValues(alpha: 0.08),
        Colors.transparent,
      ];
    }
    return [
      brandBlue.withValues(alpha: 0.12),
      brandGlow.withValues(alpha: 0.06),
      Colors.transparent,
    ];
  }

  static Color cardSurface(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return slate.withValues(alpha: 0.72);
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
    return const Color(0xFF9CA3AF);
  }

  static Color bottomNavBarShell(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return slate.withValues(alpha: 0.92);
    }
    return lightSurface.withValues(alpha: 0.88);
  }

  static Color border(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return Colors.white.withValues(alpha: 0.08);
    }
    return lightBorder;
  }
}
