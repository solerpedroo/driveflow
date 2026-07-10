import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_elevation.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/df_haptics.dart';

enum DfButtonVariant { primary, outlined, tonal, gradient }

/// Botão padronizado do Design System v2 com press-scale e gradiente hero.
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
  });

  final String label;
  final VoidCallback? onPressed;
  final DfButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final Widget? leading;
  final bool expand;

  @override
  State<DfButton> createState() => _DfButtonState();
}

class _DfButtonState extends State<DfButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = !widget.isLoading && widget.onPressed != null;

    final child = widget.isLoading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
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
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  style: widget.variant == DfButtonVariant.gradient
                      ? const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        )
                      : null,
                ),
              ),
            ],
          );

    Widget button = switch (widget.variant) {
      DfButtonVariant.gradient => _GradientButton(
          onPressed: enabled ? widget.onPressed : null,
          child: child,
        ),
      DfButtonVariant.primary => FilledButton(
          onPressed: enabled ? widget.onPressed : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
            elevation: 0,
          ),
          child: child,
        ),
      DfButtonVariant.outlined => OutlinedButton(
          onPressed: enabled ? widget.onPressed : null,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          ),
          child: child,
        ),
      DfButtonVariant.tonal => FilledButton.tonal(
          onPressed: enabled ? widget.onPressed : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          ),
          child: child,
        ),
    };

    button = AnimatedScale(
      scale: _pressed && enabled ? 0.97 : 1.0,
      duration: DriveFlowMotion.fast,
      curve: DriveFlowMotion.standard,
      child: Listener(
        onPointerDown: enabled
            ? (_) {
                DfHaptics.light();
                setState(() => _pressed = true);
              }
            : null,
        onPointerUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onPointerCancel: enabled ? (_) => setState(() => _pressed = false) : null,
        child: button,
      ),
    );

    if (!widget.expand) {
      return Semantics(button: true, label: widget.label, child: button);
    }
    return Semantics(
      button: true,
      label: widget.label,
      child: SizedBox(width: double.infinity, child: button),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.lgAll,
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppGradients.primaryButton(brightness),
            borderRadius: AppRadius.lgAll,
            boxShadow: AppElevation.brandGlow(brightness),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
