import 'package:flutter/material.dart';

import '../../../../shared/widgets/design_system/df_button.dart';

/// Botão primário de auth — delega para [DfButton].
@Deprecated('Use DfButton. Será removido em v2.1.')
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DfButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
    );
  }
}

/// Botão secundário (Google, links).
@Deprecated('Use DfButton com variant outlined. Será removido em v2.1.')
class AuthOutlinedButton extends StatelessWidget {
  const AuthOutlinedButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return DfButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      leading: leading,
      variant: DfButtonVariant.outlined,
    );
  }
}
