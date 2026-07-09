import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import 'df_button.dart';

/// Scaffold compartilhado para formulários (app bar + scroll + ações).
class DfFormScaffold extends StatelessWidget {
  const DfFormScaffold({
    required this.title,
    required this.child,
    required this.submitLabel,
    required this.onSubmit,
    super.key,
    this.isLoading = false,
    this.secondaryAction,
  });

  final String title;
  final Widget child;
  final String submitLabel;
  final VoidCallback? onSubmit;
  final bool isLoading;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              child: child,
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (secondaryAction != null) ...[
                  secondaryAction!,
                  const SizedBox(height: AppSpacing.sm),
                ],
                DfButton(
                  label: submitLabel,
                  onPressed: onSubmit,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
