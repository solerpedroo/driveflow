import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'df_button.dart';
import '../driveflow_gradient_background.dart';

/// Scaffold compartilhado para formulários — gradiente Mescla + ações fixas.
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
    final brightness = Theme.of(context).brightness;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: brightness == Brightness.dark
          ? AppColors.darkOverlay
          : AppColors.lightOverlay,
      child: DriveFlowGradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            backgroundColor: Colors.transparent,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    AppSpacing.sm,
                    AppSpacing.screenHorizontal,
                    AppSpacing.lg,
                  ),
                  child: child,
                ),
              ),
              SafeArea(
                minimum: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DfButton(
                      label: submitLabel,
                      onPressed: onSubmit,
                      isLoading: isLoading,
                    ),
                    if (secondaryAction != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      secondaryAction!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
