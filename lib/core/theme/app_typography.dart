import 'package:flutter/material.dart';

/// Tipografia estilo SF Pro / iOS Human Interface Guidelines.
abstract final class AppTypography {
  static TextTheme build(Brightness brightness) {
    final label = brightness == Brightness.dark ? Colors.white : Colors.black;
    final secondary = const Color(0xFF8E8E93);

    return TextTheme(
      displayLarge: iosLargeTitle(brightness).copyWith(color: label),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.36,
        color: label,
      ),
      displaySmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.35,
        color: label,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.35,
        color: label,
      ),
      headlineMedium: iosHeadline(brightness).copyWith(color: label),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.38,
        color: label,
      ),
      titleLarge: iosHeadline(brightness).copyWith(color: label),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.24,
        color: label,
      ),
      titleSmall: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.24,
        color: label,
      ),
      bodyLarge: iosBody(brightness).copyWith(color: label),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.24,
        color: label,
      ),
      bodySmall: iosFootnote(brightness).copyWith(color: secondary),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.24,
        color: label,
      ),
      labelMedium: iosCaption(brightness).copyWith(color: secondary),
      labelSmall: iosCaption(brightness).copyWith(color: secondary),
    );
  }

  static TextStyle iosLargeTitle(Brightness brightness) {
    return TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.37,
      color: brightness == Brightness.dark ? Colors.white : Colors.black,
    );
  }

  static TextStyle iosHeadline(Brightness brightness) {
    return TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.41,
      color: brightness == Brightness.dark ? Colors.white : Colors.black,
    );
  }

  static TextStyle iosBody(Brightness brightness) {
    return TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.41,
      color: brightness == Brightness.dark ? Colors.white : Colors.black,
    );
  }

  static TextStyle iosFootnote(Brightness brightness) {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.08,
      color: const Color(0xFF8E8E93),
    );
  }

  static TextStyle iosCaption(Brightness brightness) {
    return TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.12,
      color: const Color(0xFF8E8E93),
    );
  }

  /// Cabeçalho de seção agrupada iOS (Settings).
  static TextStyle iosSectionHeader(Brightness brightness) {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.08,
      color: const Color(0xFF8E8E93),
    );
  }

  static TextStyle labelCaps(Brightness brightness) {
    return iosSectionHeader(brightness).copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
    );
  }
}
