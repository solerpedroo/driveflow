import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Transição fade + micro-slide para rotas empilhadas.
class DriveFlowFadeSlideTransitionsBuilder extends PageTransitionsBuilder {
  const DriveFlowFadeSlideTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.025),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

PageTransitionsTheme get driveFlowPageTransitionsTheme {
  return PageTransitionsTheme(
    builders: {
      for (final platform in TargetPlatform.values)
        platform: const DriveFlowFadeSlideTransitionsBuilder(),
    },
  );
}

ThemeData buildDriveFlowLightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.skyBlue,
    brightness: Brightness.light,
    primary: AppColors.skyBlueDim,
    onPrimary: Colors.white,
    secondary: const Color(0xFF6366F1),
    surface: AppColors.lightSurface,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    textTheme: AppTypography.build(Brightness.light),
    scaffoldBackgroundColor: AppColors.lightBackground,
    pageTransitionsTheme: driveFlowPageTransitionsTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.deepNavy,
      centerTitle: false,
      titleTextStyle: AppTypography.build(Brightness.light).titleLarge?.copyWith(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.w700,
          ),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: AppColors.glassBorderLight),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.glassBorderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.skyBlueDim, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: AppColors.textSecondaryLight.withValues(alpha: 0.8)),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.glassBorderLight,
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

ThemeData buildDriveFlowDarkTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.skyBlue,
    brightness: Brightness.dark,
    primary: AppColors.skyBlue,
    onPrimary: AppColors.deepNavy,
    secondary: const Color(0xFF818CF8),
    surface: AppColors.midnight,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    textTheme: AppTypography.build(Brightness.dark),
    scaffoldBackgroundColor: AppColors.deepNavy,
    pageTransitionsTheme: driveFlowPageTransitionsTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      centerTitle: false,
      titleTextStyle: AppTypography.build(Brightness.dark).titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.slate.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.glassBorder),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.midnight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.skyBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.8)),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.glassBorder,
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
