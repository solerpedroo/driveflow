import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/validators.dart';

import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_text_field.dart';
import '../../domain/entities/receipt_scan_result.dart';
import '../providers/receipt_ocr_providers.dart';
import '../../../../shared/widgets/design_system/df_filter_pill.dart';

/// Dados confirmados pelo usuário após revisão do OCR.
class ReceiptScanConfirmation {
  const ReceiptScanConfirmation({
    required this.amount,
    required this.date,
    required this.category,
    required this.description,
    required this.imageFile,
  });

  final double amount;
  final DateTime date;
  final ExpenseCategory category;
  final String? description;
  final File imageFile;
}

Future<ReceiptScanConfirmation?> showReceiptScanReviewSheet({
  required BuildContext context,
  required ReceiptScanResult scan,
  required File imageFile,
}) {
  return showModalBottomSheet<ReceiptScanConfirmation>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => ReceiptScanReviewSheet(
      scan: scan,
      imageFile: imageFile,
    ),
  );
}

/// Revisão humana obrigatória antes de preencher o formulário de despesa.
class ReceiptScanReviewSheet extends HookConsumerWidget {
  const ReceiptScanReviewSheet({
    required this.scan,
    required this.imageFile,
    super.key,
  });

  final ReceiptScanResult scan;
  final File imageFile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formKey = useMemoized(GlobalKey<FormState>.new);

    final amountController = useTextEditingController(
      text: scan.amount != null ? CurrencyFormatter.format(scan.amount!) : '',
    );
    final descriptionController =
        useTextEditingController(text: scan.description ?? '');
    final selectedCategory =
        useState(scan.suggestedCategory ?? ExpenseCategory.other);
    final selectedDate = useState(scan.date ?? DateTime.now());

    Future<void> pickDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate.value,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 1)),
        locale: const Locale('pt', 'BR'),
      );
      if (picked != null) selectedDate.value = picked;
    }

    void discard() {
      ref.read(receiptOcrControllerProvider.notifier).logDiscarded();
      Navigator.pop(context);
    }

    void confirm() {
      if (!(formKey.currentState?.validate() ?? false)) return;
      final amount = CurrencyFormatter.tryParse(amountController.text);
      if (amount == null) return;

      ref.read(receiptOcrControllerProvider.notifier).logConfirmed();
      Navigator.pop(
        context,
        ReceiptScanConfirmation(
          amount: amount,
          date: selectedDate.value,
          category: selectedCategory.value,
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          imageFile: imageFile,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: 24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Revisar comprovante', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Confira os dados detectados antes de usar no formulário.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryLabel(theme),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  imageFile,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  cacheWidth: (MediaQuery.devicePixelRatioOf(context) *
                          MediaQuery.sizeOf(context).width)
                      .round()
                      .clamp(320, 1280),
                  cacheHeight:
                      (MediaQuery.devicePixelRatioOf(context) * 160).round(),
                ),
              ),
              const SizedBox(height: 16),
              DfTextField(
                controller: amountController,
                label: 'Valor (R\$)',
                hint: 'R\$ 45,00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.brlAmount,
              ),
              if (scan.hasLowConfidenceAmount) ...[
                const SizedBox(height: 4),
                Text(
                  'Confira o valor — detecção com baixa confiança',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              DfTextField(
                controller: descriptionController,
                label: 'Estabelecimento / descrição',
                hint: 'Nome do local',
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data'),
                subtitle: Text(
                  DateUtilsDriveFlow.dayMonthYear.format(selectedDate.value),
                ),
                trailing: Icon(
                  Icons.calendar_today_outlined,
                  color: scan.hasLowConfidenceDate
                      ? theme.colorScheme.error
                      : null,
                ),
                onTap: pickDate,
              ),
              const SizedBox(height: 8),
              Text('Categoria sugerida', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kExpenseCategories.map((category) {
                  return DfFilterPill(
                    icon: category.icon,
                    label: category.label,
                    selected: selectedCategory.value == category,
                    accentColor: AppColors.expenseCoral,
                    onSelected: () => selectedCategory.value = category,
                  );
                }).toList(growable: false),
              ),
              const SizedBox(height: 20),
              DfButton(
                label: 'Usar estes dados',
                onPressed: confirm,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: discard,
                child: const Text('Descartar leitura'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
