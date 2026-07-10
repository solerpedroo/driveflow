import 'package:flutter/cupertino.dart';

import 'app_colors.dart';
import 'app_typography.dart';

CupertinoThemeData buildDriveFlowCupertinoLightTheme() {
  return CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.systemBlue,
    primaryContrastingColor: CupertinoColors.white,
    barBackgroundColor: AppColors.iosBarBackgroundLight,
    scaffoldBackgroundColor: AppColors.iosGroupedBackground,
    textTheme: CupertinoTextThemeData(
      textStyle: AppTypography.iosBody(Brightness.light),
      navTitleTextStyle: AppTypography.iosHeadline(Brightness.light),
      navLargeTitleTextStyle: AppTypography.iosLargeTitle(Brightness.light),
      tabLabelTextStyle: AppTypography.iosCaption(Brightness.light),
    ),
  );
}

CupertinoThemeData buildDriveFlowCupertinoDarkTheme() {
  return CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.systemBlue,
    primaryContrastingColor: CupertinoColors.white,
    barBackgroundColor: AppColors.iosBarBackgroundDark,
    scaffoldBackgroundColor: AppColors.iosGroupedBackgroundDark,
    textTheme: CupertinoTextThemeData(
      textStyle: AppTypography.iosBody(Brightness.dark),
      navTitleTextStyle: AppTypography.iosHeadline(Brightness.dark),
      navLargeTitleTextStyle: AppTypography.iosLargeTitle(Brightness.dark),
      tabLabelTextStyle: AppTypography.iosCaption(Brightness.dark),
    ),
  );
}
