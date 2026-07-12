import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure_message.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../providers/reports_providers.dart';

/// Botões de exportação PDF/CSV — tier premium.
class ReportExportActions extends ConsumerWidget {
  const ReportExportActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final exportState = ref.watch(reportsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DfButton(
          label: 'Exportar PDF',
          icon: Icons.picture_as_pdf_outlined,
          variant: DfButtonVariant.gradient,
          isLoading: exportState.isLoading,
          onPressed: exportState.isLoading
              ? null
              : () => ref.read(reportsControllerProvider.notifier).exportPdf(),
        ),
        const SizedBox(height: AppSpacing.sm),
        DfButton(
          label: 'Exportar CSV',
          icon: Icons.table_chart_outlined,
          variant: DfButtonVariant.tonal,
          isLoading: exportState.isLoading,
          onPressed: exportState.isLoading
              ? null
              : () => ref.read(reportsControllerProvider.notifier).exportCsv(),
        ),
        if (exportState.hasError) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            FailureMessage.forObject(exportState.error),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
