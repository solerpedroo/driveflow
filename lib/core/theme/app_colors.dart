import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tokens iOS / Cupertino — system colors + azul Apple.
abstract final class AppColors {
  // iOS system blue (acento principal)
  static const Color systemBlue = Color(0xFF007AFF);
  static const Color systemBlueDark = Color(0xFF0A84FF);

  // Brand aliases
  static const Color brandBlue = systemBlue;
  static const Color brandBlueDark = Color(0xFF0056CC);
  static const Color brandBlueDeep = Color(0xFF003D99);
  static const Color brandGlow = Color(0xFF5AC8FA);
  static const Color brandNavy = Color(0xFF000000);

  static const Color skyBlue = systemBlue;
  static const Color skyBlueDim = brandBlueDark;
  static const Color skyBlueSoft = brandGlow;

  static const Color deepNavy = Color(0xFF000000);
  static const Color midnight = Color(0xFF1C1C1E);
  static const Color slate = Color(0xFF2C2C2E);

  static const Color electricTeal = systemBlue;
  static const Color electricTealDim = brandBlueDark;

  // Semantic
  static const Color profitGreen = Color(0xFF34C759);
  static const Color expenseCoral = Color(0xFFFF3B30);
  static const Color warningAmber = Color(0xFFFF9500);
  static const Color infoBlue = Color(0xFF5AC8FA);

  // iOS light surfaces
  static const Color iosGroupedBackground = Color(0xFFF2F2F7);
  static const Color iosSecondaryGrouped = Color(0xFFFFFFFF);
  static const Color iosTertiaryGrouped = Color(0xFFF2F2F7);
  static const Color iosSeparator = Color(0x4C3C3C43);
  static const Color iosLabel = Color(0xFF000000);
  static const Color iosSecondaryLabel = Color(0x993C3C43);
  static const Color iosBarBackgroundLight = Color(0xF0F9F9F9);

  // iOS dark surfaces
  static const Color iosGroupedBackgroundDark = Color(0xFF000000);
  static const Color iosSecondaryGroupedDark = Color(0xFF1C1C1E);
  static const Color iosTertiaryGroupedDark = Color(0xFF2C2C2E);
  static const Color iosSeparatorDark = Color(0xA6545458);
  static const Color iosBarBackgroundDark = Color(0xB31C1C1E);

  // Legacy aliases
  static const Color lightBackground = iosGroupedBackground;
  static const Color lightSurface = iosSecondaryGrouped;
  static const Color lightMuted = iosTertiaryGrouped;
  static const Color lightBorder = Color(0xFFC6C6C8);

  static const Color textPrimary = iosLabel;
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textSecondaryLight = iosSecondaryLabel;

  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassBorderLight = Color(0xFFC6C6C8);

  static const SystemUiOverlayStyle darkOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: iosGroupedBackgroundDark,
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
    final bg = groupedBackground(brightness);
    return [bg, bg];
  }

  static List<Color> ambientGradient(Brightness brightness) {
    return shellGradient(brightness);
  }

  static List<Color> accentGlow(Brightness brightness) {
    return [Colors.transparent, Colors.transparent];
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
    if (theme.brightness == Brightness.dark) {
      return const Color(0xFF8E8E93);
    }
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
