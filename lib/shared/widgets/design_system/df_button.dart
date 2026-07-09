import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

enum DfButtonVariant { primary, outlined, tonal }

/// Botão padronizado do Design System v2.
class DfButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.sm),
              ],
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(child: Text(label)),
            ],
          );

    final button = switch (variant) {
      DfButtonVariant.primary => FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdAll,
            ),
          ),
          child: child,
        ),
      DfButtonVariant.outlined => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdAll,
            ),
          ),
          child: child,
        ),
      DfButtonVariant.tonal => FilledButton.tonal(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdAll,
            ),
          ),
          child: child,
        ),
    };

    if (!expand) return Semantics(button: true, label: label, child: button);
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(width: double.infinity, child: button),
    );
  }
}
