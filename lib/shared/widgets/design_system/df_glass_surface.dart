import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_elevation.dart';
import '../../../core/theme/app_radius.dart';

/// Superfície glass reutilizável — frosted blur para nav, composer, sheets.
class DfGlassSurface extends StatelessWidget {
  const DfGlassSurface({
    required this.child,
    super.key,
    this.borderRadius,
    this.padding,
    this.sigma = 22,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double sigma;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final radius = borderRadius ?? AppRadius.xlAll;
    final fill = brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.72);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: radius,
            border: AppElevation.rimLight(brightness),
            boxShadow: AppElevation.navShellShadow(brightness),
          ),
          child: padding == null ? child : Padding(padding: padding!, child: child),
        ),
      ),
    );
  }
}
