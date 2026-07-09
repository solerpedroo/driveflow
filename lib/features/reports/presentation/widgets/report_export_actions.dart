import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../providers/reports_providers.dart';

/// Botões de exportação PDF/CSV.
class ReportExportActions extends ConsumerWidget {
  const ReportExportActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final exportState = ref.watch(reportsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: exportState.isLoading
              ? null
              : () => ref.read(reportsControllerProvider.notifier).exportPdf(),
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('Exportar PDF'),
        ),
        const SizedBox(height: AppSpacing.sm),
        FilledButton.tonalIcon(
          onPressed: exportState.isLoading
              ? null
              : () => ref.read(reportsControllerProvider.notifier).exportCsv(),
          icon: const Icon(Icons.table_chart_outlined),
          label: const Text('Exportar CSV'),
        ),
        if (exportState.hasError) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            exportState.error.toString(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
