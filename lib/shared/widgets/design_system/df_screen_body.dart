import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Padding padrão das abas — ritmo vertical unificado.
abstract final class DfScreenBody {
  static const EdgeInsets padding = EdgeInsets.fromLTRB(
    AppSpacing.screenHorizontal,
    AppSpacing.md,
    AppSpacing.screenHorizontal,
    AppSpacing.xl,
  );

  static const double sectionGap = AppSpacing.sectionGap;
}
