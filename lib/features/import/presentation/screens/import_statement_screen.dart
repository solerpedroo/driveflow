import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../authentication/presentation/widgets/auth_primary_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/services/import_file_validator.dart';
import '../providers/import_providers.dart';
import '../widgets/import_preview_table.dart';

/// Tela de importação de extratos CSV/OFX.
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar extrato'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Arquivo', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'CSV (Nubank, Inter, genérico) ou OFX. '
                    'Máx. 5 MB e 2.000 linhas. Processado apenas em memória.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: mutation.isLoading ? null : pickFile,
                    icon: const Icon(Icons.upload_file_outlined),
                    label: Text(fileName.value ?? 'Selecionar arquivo'),
                  ),
                ],
              ),
            ),
            if (preview.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Preview ($selectedCount selecionadas)',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(importControllerProvider.notifier)
                        .toggleAll(true),
                    child: const Text('Todas'),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(importControllerProvider.notifier)
                        .toggleAll(false),
                    child: const Text('Nenhuma'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ImportPreviewTable(
                transactions: preview,
                onToggle: (lineIndex, selected) => ref
                    .read(importControllerProvider.notifier)
                    .toggleSelection(lineIndex, selected),
              ),
              if (preview.length > 50)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Exibindo 50 de ${preview.length} linhas.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: 16),
              AuthPrimaryButton(
                label: 'Importar selecionadas',
                isLoading: mutation.isLoading,
                onPressed:
                    selectedCount == 0 ? null : importSelected,
              ),
            ],
            if (mutation.hasError) ...[
              const SizedBox(height: 12),
              Text(
                mutation.error.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
