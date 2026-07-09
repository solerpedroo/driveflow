import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tipografia DriveFlow — Plus Jakarta Sans + Inter (sem fontes de código).
abstract final class AppTypography {
  static TextTheme build(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    final display = GoogleFonts.plusJakartaSansTextTheme(base);
    final body = GoogleFonts.interTextTheme(base);

    return TextTheme(
      displayLarge: display.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
      ),
      displayMedium: display.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      displaySmall: display.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: body.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      titleMedium: body.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: body.titleSmall?.copyWith(fontWeight: FontWeight.w500),
      bodyLarge: body.bodyLarge,
      bodyMedium: body.bodyMedium,
      bodySmall: body.bodySmall,
      labelLarge: body.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelMedium: body.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelSmall: body.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    );
  }
}
