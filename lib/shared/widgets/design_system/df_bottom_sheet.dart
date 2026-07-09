import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// Bottom sheet padronizado do Design System v2.
abstract final class DfBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            0,
            AppSpacing.screenHorizontal,
            AppSpacing.screenHorizontal + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              child,
            ],
          ),
        );
      },
    );
  }
}
