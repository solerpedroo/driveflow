import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografia híbrida — escala iOS + Plus Jakarta/Inter (ReuniAI editorial).
abstract final class AppTypography {
  static TextTheme build(Brightness brightness) {
    final label = brightness == Brightness.dark ? Colors.white : AppColors.brandNavy;
    final secondary = const Color(0xFF8E8E93);
    final base = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    final display = GoogleFonts.plusJakartaSansTextTheme(base);
    final body = GoogleFonts.interTextTheme(base);

    return TextTheme(
      displayLarge: display.displayLarge?.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: label,
      ),
      displayMedium: display.displayMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: label,
      ),
      displaySmall: display.displaySmall?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: label,
      ),
      headlineLarge: iosHeadline(brightness).copyWith(
        fontFamily: display.headlineLarge?.fontFamily,
        color: label,
      ),
      headlineMedium: iosLargeTitle(brightness).copyWith(
        fontFamily: display.headlineMedium?.fontFamily,
        color: label,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: label,
      ),
      titleLarge: iosHeadline(brightness).copyWith(color: label),
      titleMedium: body.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: label,
      ),
      titleSmall: body.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: label,
      ),
      bodyLarge: iosBody(brightness).copyWith(
        fontFamily: body.bodyLarge?.fontFamily,
        color: label,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        fontSize: 15,
        color: label,
      ),
      bodySmall: iosFootnote(brightness),
      labelLarge: body.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: label,
      ),
      labelMedium: iosCaption(brightness),
      labelSmall: iosCaption(brightness).copyWith(color: secondary),
    );
  }

  static TextStyle iosLargeTitle(Brightness brightness) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
      color: brightness == Brightness.dark ? Colors.white : AppColors.brandNavy,
    );
  }

  static TextStyle iosHeadline(Brightness brightness) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: brightness == Brightness.dark ? Colors.white : AppColors.brandNavy,
    );
  }

  static TextStyle iosBody(Brightness brightness) {
    return GoogleFonts.inter(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.2,
      color: brightness == Brightness.dark ? Colors.white : AppColors.textPrimary,
    );
  }

  static TextStyle iosFootnote(Brightness brightness) {
    return GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF8E8E93),
    );
  }

  static TextStyle iosCaption(Brightness brightness) {
    return GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.12,
      color: const Color(0xFF8E8E93),
    );
  }

  static TextStyle iosSectionHeader(Brightness brightness) {
    return GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.4,
      color: const Color(0xFF8E8E93),
    );
  }

  /// ReuniAI — label caps editorial.
  static TextStyle labelCaps(Brightness brightness) {
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
      color: const Color(0xFF737373),
    );
  }
}
