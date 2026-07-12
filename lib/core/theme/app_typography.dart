import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografia DriveFlow — Geist (Google Fonts) em toda a escala.
abstract final class AppTypography {
  /// Roboto offline nos testes — evita fetch de Geist no binding de widget.
  @visibleForTesting
  static bool useRobotoInTests = false;

  static TextStyle _geist({
    required double fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
    List<FontFeature>? fontFeatures,
  }) {
    if (useRobotoInTests) {
      return TextStyle(
        fontFamily: 'Roboto',
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
        fontFeatures: fontFeatures,
      );
    }
    return GoogleFonts.geist(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
      fontFeatures: fontFeatures,
    );
  }

  static TextTheme build(Brightness brightness) {
    final label =
        brightness == Brightness.dark ? Colors.white : AppColors.textPrimary;
    final secondary = brightness == Brightness.dark
        ? const Color(0xFF98989F)
        : const Color(0xFF6B7280);
    final base = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    final geist =
        useRobotoInTests ? base : GoogleFonts.geistTextTheme(base);

    return TextTheme(
      displayLarge: geist.displayLarge?.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.1,
        color: label,
      ),
      displayMedium: geist.displayMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.7,
        height: 1.15,
        color: label,
      ),
      displaySmall: geist.displaySmall?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: label,
      ),
      headlineLarge: iosHeadline(brightness).copyWith(color: label),
      headlineMedium: iosLargeTitle(brightness).copyWith(color: label),
      headlineSmall: geist.headlineSmall?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.35,
        color: label,
      ),
      titleLarge: iosHeadline(brightness).copyWith(color: label),
      titleMedium: geist.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: label,
      ),
      titleSmall: geist.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: label,
      ),
      bodyLarge: iosBody(brightness).copyWith(color: label),
      bodyMedium: geist.bodyMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.15,
        height: 1.45,
        color: label,
      ),
      bodySmall: iosFootnote(brightness),
      labelLarge: geist.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: label,
      ),
      labelMedium: iosCaption(brightness),
      labelSmall: iosCaption(brightness).copyWith(color: secondary),
    );
  }

  static TextStyle iosLargeTitle(Brightness brightness) {
    return _geist(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
      height: 1.1,
      color: brightness == Brightness.dark ? Colors.white : AppColors.textPrimary,
    );
  }

  static TextStyle iosHeadline(Brightness brightness) {
    return _geist(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: brightness == Brightness.dark ? Colors.white : AppColors.textPrimary,
    );
  }

  static TextStyle iosBody(Brightness brightness) {
    return _geist(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.2,
      height: 1.4,
      color: brightness == Brightness.dark ? Colors.white : AppColors.textPrimary,
    );
  }

  static TextStyle iosFootnote(Brightness brightness) {
    return _geist(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.08,
      color: brightness == Brightness.dark
          ? const Color(0xFF98989F)
          : const Color(0xFF6B7280),
    );
  }

  static TextStyle iosCaption(Brightness brightness) {
    return _geist(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.05,
      color: brightness == Brightness.dark
          ? const Color(0xFF98989F)
          : const Color(0xFF6B7280),
    );
  }

  static TextStyle iosSectionHeader(Brightness brightness) {
    return _geist(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.05,
      color: brightness == Brightness.dark
          ? const Color(0xFF98989F)
          : const Color(0xFF6B7280),
    );
  }

  /// Label de seção — sentence-case (não ALL CAPS).
  static TextStyle labelCaps(Brightness brightness) {
    return _geist(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.05,
      color: brightness == Brightness.dark
          ? const Color(0xFF98989F)
          : const Color(0xFF6B7280),
    );
  }

  /// Métrica financeira — tabular figures.
  static TextStyle metric(
    Brightness brightness, {
    double fontSize = 34,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
  }) {
    return _geist(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: -1.1,
      height: 1.05,
      color: color ??
          (brightness == Brightness.dark ? Colors.white : AppColors.textPrimary),
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
