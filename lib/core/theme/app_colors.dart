import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fusão DriveFlow — Cupertino (estrutura) + ReuniAI (marca) + Mescla (hero/fintech).
abstract final class AppColors {
  // ReuniAI — identidade azul premium
  static const Color brandBlue = Color(0xFF0064F5);
  static const Color brandBlueDark = Color(0xFF0047B8);
  static const Color brandBlueDeep = Color(0xFF002D6E);
  static const Color brandGlow = Color(0xFFB8D4FF);
  static const Color brandNavy = Color(0xFF0A192F);

  // Cupertino system blue (fallback nativo)
  static const Color systemBlue = brandBlue;
  static const Color systemBlueDark = Color(0xFF0A84FF);

  static const Color skyBlue = brandBlue;
  static const Color skyBlueDim = brandBlueDark;
  static const Color skyBlueSoft = brandGlow;

  static const Color deepNavy = brandNavy;
  static const Color midnight = Color(0xFF1C1C1E);
  static const Color slate = Color(0xFF2C2C2E);

  // Mescla — acento secundário (gráficos / hero)
  static const Color mesclaIndigo = Color(0xFF4F46E5);

  static const Color electricTeal = brandBlue;
  static const Color electricTealDim = brandBlueDark;

  // Semantic (iOS + fintech)
  static const Color profitGreen = Color(0xFF34C759);
  static const Color expenseCoral = Color(0xFFFF3B30);
  static const Color warningAmber = Color(0xFFFF9500);
  static const Color infoBlue = Color(0xFF5AC8FA);

  // Cupertino grouped surfaces
  static const Color iosGroupedBackground = Color(0xFFF2F2F7);
  static const Color iosSecondaryGrouped = Color(0xFFFFFFFF);
  static const Color iosTertiaryGrouped = Color(0xFFF2F2F7);
  static const Color iosSeparator = Color(0x4C3C3C43);
  static const Color iosLabel = Color(0xFF000000);
  static const Color iosBarBackgroundLight = Color(0xF0F9F9F9);

  // Mescla shell tint (light)
  static const Color mesclaShellTop = Color(0xFFF3F5FA);

  static const Color iosGroupedBackgroundDark = Color(0xFF000000);
  static const Color iosSecondaryGroupedDark = Color(0xFF1C1C1E);
  static const Color iosTertiaryGroupedDark = Color(0xFF2C2C2E);
  static const Color iosSeparatorDark = Color(0xA6545458);
  static const Color iosBarBackgroundDark = Color(0xB31C1C1E);

  static const Color lightBackground = iosGroupedBackground;
  static const Color lightSurface = iosSecondaryGrouped;
  static const Color lightMuted = iosTertiaryGrouped;
  static const Color lightBorder = Color(0xFFEBEBEB);

  static const Color textPrimary = Color(0xFF252525);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textSecondaryLight = Color(0xFF737373);

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
    systemNavigationBarColor: iosGroupedBackground,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static Color groupedBackground(Brightness brightness) {
    return brightness == Brightness.dark
        ? iosGroupedBackgroundDark
        : iosGroupedBackground;
  }

  static Color secondaryGrouped(Brightness brightness) {
    return brightness == Brightness.dark
        ? iosSecondaryGroupedDark
        : iosSecondaryGrouped;
  }

  static List<Color> shellGradient(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const [brandNavy, Color(0xFF0F1419)];
    }
    return const [mesclaShellTop, iosGroupedBackground, Color(0xFFFFFFFF)];
  }

  static List<Color> ambientGradient(Brightness brightness) {
    return shellGradient(brightness);
  }

  static List<Color> accentGlow(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        brandBlue.withValues(alpha: 0.18),
        brandGlow.withValues(alpha: 0.06),
        Colors.transparent,
      ];
    }
    return [
      brandBlue.withValues(alpha: 0.10),
      brandGlow.withValues(alpha: 0.05),
      Colors.transparent,
    ];
  }

  static Color cardSurface(ThemeData theme) {
    return secondaryGrouped(theme.brightness);
  }

  static Color mutedSurface(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return iosTertiaryGroupedDark;
    }
    return iosTertiaryGrouped;
  }

  static Color secondaryLabel(ThemeData theme) {
    return const Color(0xFF8E8E93);
  }

  static Color bottomNavInactive(ThemeData theme) {
    return const Color(0xFF8E8E93);
  }

  static Color bottomNavBarShell(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return iosBarBackgroundDark;
    }
    return iosBarBackgroundLight;
  }

  static Color border(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return iosSeparatorDark;
    }
    return iosSeparator;
  }

  static Color separator(ThemeData theme) {
    return border(theme);
  }
}
