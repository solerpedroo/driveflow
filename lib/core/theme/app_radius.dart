import 'package:flutter/material.dart';

/// Raios iOS — grouped inset 10pt, sheets 13pt, hero 16pt.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 16;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));

  static const BorderRadius grouped = BorderRadius.all(Radius.circular(10));
}
