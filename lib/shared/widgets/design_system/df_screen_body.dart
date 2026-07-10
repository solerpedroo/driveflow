import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Padding padrão das abas — alinhado ao Mescla (20h, 8t, 24 entre seções).
abstract final class DfScreenBody {
  static const EdgeInsets padding = EdgeInsets.fromLTRB(
    AppSpacing.screenHorizontal,
    AppSpacing.sm,
    AppSpacing.screenHorizontal,
    AppSpacing.lg,
  );

  static const double sectionGap = 24;
}
