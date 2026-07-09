import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Campo de texto padronizado do Design System v2.
class DfTextField extends StatelessWidget {
  const DfTextField({
    required this.controller,
    required this.label,
    super.key,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.autofillHints,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      textField: true,
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.secondaryLabel(theme),
              letterSpacing: 0.9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            textInputAction: textInputAction,
            validator: validator,
            autofillHints: autofillHints,
            onFieldSubmitted: onFieldSubmitted,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 22) : null,
              suffixIcon: suffixIcon,
            ),
          ),
        ],
      ),
    );
  }
}
