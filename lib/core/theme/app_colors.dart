import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Paleta DriveFlow — azul de marca + superfícies em camadas (Wallet / HIG).
abstract final class AppColors {
  // Marca
  static const Color brandBlue = Color(0xFF0064F5);
  static const Color brandBlueDark = Color(0xFF0047B8);
  static const Color brandBlueDeep = Color(0xFF002D6E);
  static const Color brandGlow = Color(0xFFB8D4FF);
  static const Color brandNavy = Color(0xFF0A192F);

  // Aliases de compatibilidade (sem drift para indigo/roxo)
  static const Color systemBlue = brandBlue;
  static const Color systemBlueDark = Color(0xFF0A84FF);
  static const Color skyBlue = brandBlue;
  static const Color skyBlueDim = brandBlueDark;
  static const Color skyBlueSoft = brandGlow;
  static const Color deepNavy = brandNavy;
  static const Color midnight = Color(0xFF1C1C1E);
  static const Color slate = Color(0xFF2C2C2E);
  static const Color electricTeal = brandBlue;
  static const Color electricTealDim = brandBlueDark;

  /// Alias legado — aponta para navy profundo (sem indigo/roxo).
  static const Color mesclaIndigo = brandBlueDeep;

  // Semântica (iOS system)
  static const Color profitGreen = Color(0xFF34C759);
  static const Color expenseCoral = Color(0xFFFF3B30);
  static const Color warningAmber = Color(0xFFFF9500);
  static const Color infoBlue = Color(0xFF5AC8FA);

  // Superfícies light — camadas (não flat único)
  static const Color iosGroupedBackground = Color(0xFFF2F4F8);
  static const Color iosSecondaryGrouped = Color(0xFFFFFFFF);
  static const Color iosTertiaryGrouped = Color(0xFFE8ECF2);
  static const Color iosSeparator = Color(0x4C3C3C43);
  static const Color iosLabel = Color(0xFF0B1220);
  static const Color iosBarBackgroundLight = Color(0xF0F7F8FA);
  static const Color shellTopLight = Color(0xFFEEF2F7);

  // Superfícies dark — true black + elevated layers
  static const Color iosGroupedBackgroundDark = Color(0xFF000000);
  static const Color iosSecondaryGroupedDark = Color(0xFF1C1C1E);
  static const Color iosTertiaryGroupedDark = Color(0xFF2C2C2E);
  static const Color iosSeparatorDark = Color(0xA6545458);
  static const Color iosBarBackgroundDark = Color(0xB31C1C1E);

  static const Color lightBackground = iosGroupedBackground;
  static const Color lightSurface = iosSecondaryGrouped;
  static const Color lightMuted = iosTertiaryGrouped;
  static const Color lightBorder = Color(0xFFE2E6EE);

  static const Color textPrimary = Color(0xFF0B1220);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textSecondaryLight = Color(0xFF6B7280);

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

  /// Fundo em camadas — profundidade estática (sem mesh animado).
  static List<Color> shellGradient(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const [Color(0xFF05080F), brandNavy, Color(0xFF000000)];
    }
    return const [shellTopLight, iosGroupedBackground, Color(0xFFF8FAFC)];
  }

  static List<Color> ambientGradient(Brightness brightness) {
    return shellGradient(brightness);
  }

  static List<Color> accentGlow(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        brandBlue.withValues(alpha: 0.14),
        brandGlow.withValues(alpha: 0.04),
        Colors.transparent,
      ];
    }
    return [
      brandBlue.withValues(alpha: 0.07),
      brandGlow.withValues(alpha: 0.03),
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
    return theme.brightness == Brightness.dark
        ? const Color(0xFF98989F)
        : const Color(0xFF6B7280);
  }

  static Color bottomNavInactive(ThemeData theme) {
    return secondaryLabel(theme);
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

  /// Tint quieto para tab ativa (sem gradient glow).
  static Color navActiveFill(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return brandBlue.withValues(alpha: 0.22);
    }
    return brandBlue.withValues(alpha: 0.12);
  }

  static Color navActiveForeground(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const Color(0xFF9EC1FF);
    }
    return brandBlueDark;
  }
}
