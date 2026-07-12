import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Diálogo de confirmação — substitui AlertDialog Material cru.
class DfConfirmDialog extends StatelessWidget {
  const DfConfirmDialog({
    required this.title,
    required this.message,
    super.key,
    this.confirmLabel = 'Confirmar',
    this.cancelLabel = 'Cancelar',
    this.destructive = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => DfConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: AppColors.expenseCoral,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
