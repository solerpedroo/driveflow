import 'package:flutter/material.dart';

/// Raios de borda padronizados.
abstract final class AppRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
}
