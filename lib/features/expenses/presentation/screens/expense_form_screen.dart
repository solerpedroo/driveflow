import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../authentication/presentation/widgets/auth_primary_button.dart';
import '../../../authentication/presentation/widgets/auth_text_field.dart';
import '../../domain/entities/expense_entity.dart';
import '../providers/expenses_providers.dart';
import '../../../../shared/widgets/driveflow_glass_card.dart';

/// Formulário de criação/edição de despesa com comprovante.
class ExpenseFormScreen extends HookConsumerWidget {
  const ExpenseFormScreen({this.expense, super.key});

  final ExpenseEntity? expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final isEditing = expense != null;

    final amountController = useTextEditingController(
      text: expense != null ? CurrencyFormatter.format(expense!.amount) : '',
    );
    final descriptionController =
        useTextEditingController(text: expense?.description ?? '');
    final selectedCategory =
        useState(expense?.category ?? ExpenseCategory.other);
    final selectedDate = useState(expense?.date ?? DateTime.now());
    final receiptFile = useState<File?>(null);
    final existingReceiptUrl = expense?.receiptUrl;
    final mutation = ref.watch(expensesControllerProvider);

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

    Future<void> pickReceipt() async {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (picked != null) receiptFile.value = File(picked.path);
    }

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      final amount = CurrencyFormatter.tryParse(amountController.text);
      if (amount == null) return;

      final draft = ExpenseDraft(
        category: selectedCategory.value,
        amount: amount,
        date: selectedDate.value,
        description: descriptionController.text,
        receiptUrl: existingReceiptUrl,
      );

      final saved =
          await ref.read(expensesControllerProvider.notifier).save(
                expenseId: expense?.id,
                draft: draft,
                receiptFile: receiptFile.value,
              );
      if (saved != null && context.mounted) context.pop();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar despesa' : 'Nova despesa'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DriveFlowGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Categoria', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kExpenseCategories.map((category) {
                        return FilterChip(
                          avatar: Icon(category.icon, size: 18),
                          label: Text(category.label),
                          selected: selectedCategory.value == category,
                          onSelected: (_) =>
                              selectedCategory.value = category,
                        );
                      }).toList(growable: false),
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: amountController,
                      label: 'Valor (R\$)',
                      hint: 'R\$ 45,00',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: Validators.brlAmount,
                    ),
                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: descriptionController,
                      label: 'Descrição (opcional)',
                      hint: 'Pedágio BR-101',
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Data'),
                      subtitle: Text(
                        DateUtilsDriveFlow.dayMonthYear.format(selectedDate.value),
                      ),
                      trailing: const Icon(Icons.calendar_today_outlined),
                      onTap: pickDate,
                    ),
                    const SizedBox(height: 12),
                    Text('Comprovante', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    if (receiptFile.value != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          receiptFile.value!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else if (existingReceiptUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: existingReceiptUrl,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: pickReceipt,
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: Text(
                        receiptFile.value != null || existingReceiptUrl != null
                            ? 'Trocar comprovante'
                            : 'Anexar comprovante',
                      ),
                    ),
                  ],
                ),
              ),
              if (mutation.hasError) ...[
                const SizedBox(height: 12),
                Text(
                  mutation.error.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              AuthPrimaryButton(
                label: isEditing ? 'Salvar alterações' : 'Registrar despesa',
                isLoading: mutation.isLoading,
                onPressed: submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
