import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_text_field.dart';
import '../../domain/entities/recurring_expense_template.dart';
import '../../data/datasources/recurring_expense_storage.dart';
import '../providers/recurring_expense_providers.dart';

/// Card com templates de despesas recorrentes (aluguel, seguro, IPVA).
class RecurringExpenseTemplatesCard extends ConsumerWidget {
  const RecurringExpenseTemplatesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(recurringExpenseTemplatesProvider);
    final brightness = Theme.of(context).brightness;

    return DfCard(
      variant: DfCardVariant.elevated,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recorrentes',
            style: AppTypography.labelCaps(brightness),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Lançamento automático no dia configurado.',
            style: AppTypography.iosFootnote(brightness).copyWith(
              color: AppColors.secondaryLabel(Theme.of(context)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...templates.map(
            (template) => _TemplateRow(
              template: template,
              onChanged: (updated) async {
                await RecurringExpenseStorage.upsert(updated);
                ref.read(recurringExpenseTemplatesVersionProvider.notifier).state++;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateRow extends StatelessWidget {
  const _TemplateRow({
    required this.template,
    required this.onChanged,
  });

  final RecurringExpenseTemplate template;
  final ValueChanged<RecurringExpenseTemplate> onChanged;

  Future<void> _editAmount(BuildContext context) async {
    final controller = TextEditingController(
      text: template.amount > 0 ? CurrencyFormatter.format(template.amount) : '',
    );

    final amount = await showDialog<double>(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: Text(template.label),
          content: Form(
            key: formKey,
            child: DfTextField(
              controller: controller,
              label: 'Valor mensal (R\$)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: Validators.brlAmount,
              autofocus: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final parsed = CurrencyFormatter.tryParse(controller.text);
                if (parsed == null) return;
                Navigator.pop(context, parsed);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (amount == null) return;
    onChanged(template.copyWith(amount: amount, enabled: true));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountLabel = template.amount > 0
        ? CurrencyFormatter.format(template.amount)
        : 'Definir valor';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dia ${template.dayOfMonth} · $amountLabel',
                  style: AppTypography.iosFootnote(theme.brightness).copyWith(
                    color: AppColors.secondaryLabel(theme),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _editAmount(context),
            child: const Text('Valor'),
          ),
          Switch.adaptive(
            value: template.enabled && template.amount > 0,
            onChanged: template.amount > 0
                ? (enabled) => onChanged(template.copyWith(enabled: enabled))
                : null,
          ),
        ],
      ),
    );
  }
}
