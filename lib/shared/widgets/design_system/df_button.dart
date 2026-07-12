import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_elevation.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/df_haptics.dart';

enum DfButtonVariant { primary, outlined, tonal, gradient }

/// Botão premium — CTA com profundidade, outline quieto, press scale.
class DfButton extends StatefulWidget {
  const DfButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = DfButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.leading,
    this.expand = true,
    this.trailingIcon = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final DfButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final Widget? leading;
  final bool expand;

  /// Coloca [icon] à direita do label (padrão em CTAs de fluxo).
  final bool trailingIcon;

  @override
  State<DfButton> createState() => _DfButtonState();
}

class _DfButtonState extends State<DfButton> {
  bool _pressed = false;

  static const double _height = 54;

  Color get _spinnerColor {
    return switch (widget.variant) {
      DfButtonVariant.outlined || DfButtonVariant.tonal => AppColors.brandBlue,
      _ => Colors.white,
    };
  }

  Color _labelColor(ThemeData theme) {
    return switch (widget.variant) {
      DfButtonVariant.gradient || DfButtonVariant.primary => Colors.white,
      DfButtonVariant.outlined => theme.colorScheme.onSurface,
      DfButtonVariant.tonal => AppColors.brandBlue,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final enabled = !widget.isLoading && widget.onPressed != null;
    final labelColor = _labelColor(theme);

    final child = widget.isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: _spinnerColor,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: AppSpacing.sm),
              ],
              if (widget.icon != null && !widget.trailingIcon) ...[
                Icon(widget.icon, size: 18, color: labelColor),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: AppTypography.iosHeadline(brightness).copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    height: 1.1,
                  ),
                ),
              ),
              if (widget.icon != null && widget.trailingIcon) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(widget.icon, size: 18, color: labelColor),
              ],
            ],
          );

    Widget button = switch (widget.variant) {
      DfButtonVariant.gradient => _SurfaceButton(
          onPressed: enabled ? widget.onPressed : null,
          height: _height,
          decoration: BoxDecoration(
            gradient: AppGradients.brand,
            borderRadius: AppRadius.xlAll,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 0.5,
            ),
            boxShadow: onPressedShadow(enabled, brightness),
          ),
          sheen: true,
          child: child,
        ),
      DfButtonVariant.primary => _SurfaceButton(
          onPressed: enabled ? widget.onPressed : null,
          height: _height,
          decoration: BoxDecoration(
            color: AppColors.brandBlue,
            borderRadius: AppRadius.xlAll,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
              width: 0.5,
            ),
            boxShadow: onPressedShadow(enabled, brightness),
          ),
          sheen: true,
          child: child,
        ),
      DfButtonVariant.outlined => _SurfaceButton(
          onPressed: enabled ? widget.onPressed : null,
          height: _height,
          decoration: BoxDecoration(
            color: AppColors.secondaryGrouped(brightness).withValues(
              alpha: brightness == Brightness.dark ? 0.55 : 0.72,
            ),
            borderRadius: AppRadius.xlAll,
            border: Border.all(
              color: AppColors.border(theme).withValues(alpha: 0.55),
              width: 0.8,
            ),
          ),
          child: child,
        ),
      DfButtonVariant.tonal => TextButton(
          onPressed: enabled ? widget.onPressed : null,
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 44),
            foregroundColor: AppColors.brandBlue,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          child: child,
        ),
    };

    button = AnimatedOpacity(
      opacity: enabled || widget.isLoading ? 1 : 0.45,
      duration: DriveFlowMotion.fast,
      child: AnimatedScale(
        scale: _pressed && enabled ? 0.975 : 1.0,
        duration: DriveFlowMotion.fast,
        curve: Curves.easeOutCubic,
        child: Listener(
          onPointerDown: enabled
              ? (_) {
                  DfHaptics.light();
                  setState(() => _pressed = true);
                }
              : null,
          onPointerUp: enabled ? (_) => setState(() => _pressed = false) : null,
          onPointerCancel:
              enabled ? (_) => setState(() => _pressed = false) : null,
          child: button,
        ),
      ),
    );

    if (!widget.expand) {
      return Semantics(button: true, label: widget.label, child: button);
    }
    return Semantics(
      button: true,
      label: widget.label,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width =
              constraints.hasBoundedWidth && constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : MediaQuery.sizeOf(context).width;
          return SizedBox(width: width, child: button);
        },
      ),
    );
  }

  static List<BoxShadow>? onPressedShadow(bool enabled, Brightness brightness) {
    if (!enabled) return null;
    return AppElevation.brandGlow(brightness);
  }
}

class _SurfaceButton extends StatelessWidget {
  const _SurfaceButton({
    required this.onPressed,
    required this.height,
    required this.decoration,
    required this.child,
    this.sheen = false,
  });

  final VoidCallback? onPressed;
  final double height;
  final BoxDecoration decoration;
  final Widget child;
  final bool sheen;

  @override
  Widget build(BuildContext context) {
    final radius = decoration.borderRadius ?? AppRadius.xlAll;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius is BorderRadius ? radius : AppRadius.xlAll,
        splashColor: Colors.white.withValues(alpha: 0.12),
        highlightColor: Colors.white.withValues(alpha: 0.06),
        child: Ink(
          height: height,
          decoration: decoration,
          child: ClipRRect(
            borderRadius: radius is BorderRadius ? radius : AppRadius.xlAll,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (sheen)
                  const IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            Color(0x33FFFFFF),
                            Color(0x00FFFFFF),
                          ],
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
