import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_filter_pill.dart';
import '../../../../shared/widgets/design_system/df_section_header.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';
import '../../domain/services/import_file_validator.dart';
import '../providers/import_providers.dart';
import '../widgets/import_preview_table.dart';
import '../widgets/import_story_header.dart';

/// Importação de extratos — layout Mescla.
class ImportStatementScreen extends HookConsumerWidget {
  const ImportStatementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final preview = ref.watch(importPreviewProvider);
    final mutation = ref.watch(importControllerProvider);
    final fileName = useState<String?>(null);

    Future<void> pickFile() async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv', 'ofx', 'txt'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      fileName.value = file.name;

      final bytes = file.bytes ??
          (file.path != null ? await File(file.path!).readAsBytes() : null);
      if (bytes == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível ler o arquivo.')),
          );
        }
        return;
      }

      ImportFileValidator.validate(
        byteLength: bytes.length,
        lineCount: String.fromCharCodes(bytes).split('\n').length,
      );

      final content = String.fromCharCodes(bytes);
      final isOfx = file.name.toLowerCase().endsWith('.ofx');

      ref.read(importControllerProvider.notifier).parseContent(
            content: content,
            isOfx: isOfx,
          );
    }

    Future<void> importSelected() async {
      final batch = await ref
          .read(importControllerProvider.notifier)
          .importSelected();
      if (batch != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Importados: ${batch.totalImported} '
              '(${batch.importedExpenses} despesas, '
              '${batch.importedEarnings} ganhos)',
            ),
          ),
        );
        context.pop();
      }
    }

    final selectedCount =
        preview.where((item) => item.selected && !item.isDuplicate).length;

    return DfSubpageScaffold(
      title: 'Importar extrato',
      children: [
        const ImportStoryHeader(),
        DfCard(
          variant: DfCardVariant.elevated,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DfSectionHeader(title: 'Arquivo', eyebrow: 'Upload'),
              Text(
                'CSV (Nubank, Inter, genérico) ou OFX. '
                'Máx. 5 MB e 2.000 linhas. Processado apenas em memória.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 12),
              DfButton(
                label: fileName.value ?? 'Selecionar arquivo',
                icon: Icons.upload_file_outlined,
                variant: DfButtonVariant.outlined,
                isLoading: mutation.isLoading,
                onPressed: mutation.isLoading ? null : pickFile,
                expand: false,
              ),
            ],
          ),
        ),
        if (preview.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Preview ($selectedCount selecionadas)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DfFilterPill(
                label: 'Todas',
                selected: false,
                onSelected: () => ref
                    .read(importControllerProvider.notifier)
                    .toggleAll(true),
              ),
              const SizedBox(width: 8),
              DfFilterPill(
                label: 'Nenhuma',
                selected: false,
                onSelected: () => ref
                    .read(importControllerProvider.notifier)
                    .toggleAll(false),
              ),
            ],
          ),
          ImportPreviewTable(
            transactions: preview,
            onToggle: (lineIndex, selected) => ref
                .read(importControllerProvider.notifier)
                .toggleSelection(lineIndex, selected),
          ),
          if (preview.length > 50)
            Text(
              'Exibindo 50 de ${preview.length} linhas.',
              style: theme.textTheme.bodySmall,
            ),
          DfButton(
            label: 'Importar selecionadas',
            icon: Icons.cloud_download_outlined,
            variant: DfButtonVariant.gradient,
            isLoading: mutation.isLoading,
            onPressed: selectedCount == 0 ? null : importSelected,
          ),
        ],
        if (mutation.hasError)
          Text(
            mutation.error.toString(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
      ],
    );
  }
}
