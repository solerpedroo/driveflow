import 'package:flutter/services.dart';

/// Feedback háptico consistente — padrão apps premium iOS/Android.
abstract final class DfHaptics {
  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void selection() => HapticFeedback.selectionClick();
  static void success() => HapticFeedback.mediumImpact();
}
