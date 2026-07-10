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

/// Botão estilo iOS — filled azul system, cantos 12pt, sem sombra pesada.
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
                  style: widget.variant == DfButtonVariant.gradient ||
                          widget.variant == DfButtonVariant.primary
                      ? AppTypography.iosHeadline(theme.brightness).copyWith(
                          color: Colors.white,
                        )
                      : AppTypography.iosHeadline(theme.brightness).copyWith(
                          color: AppColors.brandBlue,
                        ),
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
            backgroundColor: AppColors.brandBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 50),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
            elevation: 0,
          ),
          child: child,
        ),
      DfButtonVariant.outlined => OutlinedButton(
          onPressed: enabled ? widget.onPressed : null,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 50),
            side: const BorderSide(color: AppColors.brandBlue),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          ),
          child: child,
        ),
      DfButtonVariant.tonal => TextButton(
          onPressed: enabled ? widget.onPressed : null,
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 44),
            foregroundColor: AppColors.brandBlue,
          ),
          child: child,
        ),
    };

    button = AnimatedScale(
      scale: _pressed && enabled ? 0.98 : 1.0,
      duration: DriveFlowMotion.fast,
      curve: Curves.easeInOut,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.hasBoundedWidth && constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          return SizedBox(width: width, child: button);
        },
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.lgAll,
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppGradients.brand,
            borderRadius: AppRadius.lgAll,
            boxShadow: AppElevation.brandGlow(Theme.of(context).brightness),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
