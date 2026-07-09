import 'package:flutter/material.dart';

import '../../../../shared/widgets/design_system/df_text_field.dart';

/// Campo de texto de auth — delega para [DfTextField].
@Deprecated('Use DfTextField. Será removido em v2.1.')
class AuthTextField extends StatelessWidget {
  const AuthTextField({
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
    return DfTextField(
      controller: controller,
      label: label,
      hint: hint,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      validator: validator,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      autofillHints: autofillHints,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
