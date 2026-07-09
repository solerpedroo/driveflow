import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Cabeçalho de seção reutilizável.
class DfSectionHeader extends StatelessWidget {
  const DfSectionHeader({
    required this.title,
    super.key,
    this.action,
    this.actionLabel,
  });

  final String title;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      header: true,
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: theme.textTheme.titleMedium),
          ),
          if (action != null)
            TextButton(
              onPressed: action,
              child: Text(actionLabel ?? 'Ver mais'),
            ),
        ],
      ),
    );
  }
}

/// Título de tela com padding horizontal padrão.
class DfScreenTitle extends StatelessWidget {
  const DfScreenTitle({
    required this.title,
    super.key,
    this.subtitle,
  });

  final String title;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.screenTop,
        AppSpacing.screenHorizontal,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.headlineSmall),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.md),
            subtitle!,
          ],
        ],
      ),
    );
  }
}
