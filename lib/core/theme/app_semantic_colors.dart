import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Cores semânticas além da paleta de marca.
abstract final class AppSemanticColors {
  static const Color success = AppColors.profitGreen;
  static const Color warning = AppColors.warningAmber;
  static const Color error = AppColors.expenseCoral;
  static const Color info = AppColors.infoBlue;

  /// Contraste WCAG AA para chips em fundo claro/escuro.
  static Color chipForeground(ThemeData theme, Color accent) {
    if (theme.brightness == Brightness.dark) {
      return accent;
    }
    return Color.alphaBlend(accent.withValues(alpha: 0.85), Colors.black);
  }

  static Color chartGrid(ThemeData theme) {
    return AppColors.secondaryLabel(theme).withValues(alpha: 0.18);
  }
}
