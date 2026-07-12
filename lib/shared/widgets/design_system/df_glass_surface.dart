import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_blur.dart';
import '../../../core/theme/app_elevation.dart';
import '../../../core/theme/app_radius.dart';

/// Superfície glass — frosted translúcido para nav, composer e sheets.
class DfGlassSurface extends StatelessWidget {
  const DfGlassSurface({
    required this.child,
    super.key,
    this.borderRadius,
    this.padding,
    this.sigma = AppBlur.surface,
    this.fillColor,
    this.border,
    this.boxShadow,
    this.useDefaultShadow = true,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double sigma;
  final Color? fillColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final bool useDefaultShadow;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final radius = borderRadius ?? AppRadius.xlAll;
    final fill = fillColor ??
        (brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.62));
    final resolvedShadow = useDefaultShadow
        ? (boxShadow ?? AppElevation.navShellShadow(brightness))
        : boxShadow;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: radius,
            border: border ?? AppElevation.rimLight(brightness),
            boxShadow: resolvedShadow,
          ),
          child: padding == null
              ? child
              : Padding(padding: padding!, child: child),
        ),
      ),
    );
  }
}
