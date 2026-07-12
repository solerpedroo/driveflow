import 'dart:async';

import 'package:driveflow/core/theme/app_typography.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tipografia offline + sem fetch de rede nos testes de widget/golden.
Future<void> testExecutable(Future<void> Function() testMain) async {
  AppTypography.useRobotoInTests = true;
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
