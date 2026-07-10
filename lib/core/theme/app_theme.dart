import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Transição suave estilo iOS.
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
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.03, 0),
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
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.systemBlue,
    onPrimary: Colors.white,
    secondary: AppColors.systemBlue,
    onSecondary: Colors.white,
    error: AppColors.expenseCoral,
    onError: Colors.white,
    surface: AppColors.iosSecondaryGrouped,
    onSurface: AppColors.iosLabel,
    outline: AppColors.iosSeparator,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    textTheme: AppTypography.build(Brightness.light),
    scaffoldBackgroundColor: AppColors.iosGroupedBackground,
    pageTransitionsTheme: driveFlowPageTransitionsTheme,
    splashFactory: NoSplash.splashFactory,
    highlightColor: AppColors.systemBlue.withValues(alpha: 0.08),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.iosGroupedBackground,
      foregroundColor: AppColors.iosLabel,
      centerTitle: true,
      titleTextStyle: AppTypography.iosHeadline(Brightness.light),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: AppColors.iosSecondaryGrouped,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.grouped),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.iosSeparator,
      thickness: 0.5,
      space: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.systemBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTypography.iosHeadline(Brightness.light).copyWith(
          color: Colors.white,
        ),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.iosSecondaryGrouped,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.iosSeparator),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.systemBlue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTypography.iosBody(Brightness.light).copyWith(
        color: const Color(0xFF8E8E93),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.grouped),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

ThemeData buildDriveFlowDarkTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.systemBlue,
    onPrimary: Colors.white,
    secondary: AppColors.systemBlueDark,
    onSecondary: Colors.white,
    error: AppColors.expenseCoral,
    onError: Colors.white,
    surface: AppColors.iosSecondaryGroupedDark,
    onSurface: Colors.white,
    outline: AppColors.iosSeparatorDark,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    textTheme: AppTypography.build(Brightness.dark),
    scaffoldBackgroundColor: AppColors.iosGroupedBackgroundDark,
    pageTransitionsTheme: driveFlowPageTransitionsTheme,
    splashFactory: NoSplash.splashFactory,
    highlightColor: AppColors.systemBlue.withValues(alpha: 0.12),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.iosGroupedBackgroundDark,
      foregroundColor: Colors.white,
      centerTitle: true,
      titleTextStyle: AppTypography.iosHeadline(Brightness.dark),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: AppColors.iosSecondaryGroupedDark,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.grouped),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.iosSeparatorDark,
      thickness: 0.5,
      space: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.systemBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTypography.iosHeadline(Brightness.dark).copyWith(
          color: Colors.white,
        ),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.iosSecondaryGroupedDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.iosSeparatorDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.systemBlue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTypography.iosBody(Brightness.dark).copyWith(
        color: const Color(0xFF8E8E93),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.grouped),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
