import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../authentication/presentation/widgets/auth_text_field.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../providers/maintenance_providers.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_filter_pill.dart';
import '../../../../shared/widgets/design_system/df_form_scaffold.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';

/// Formulário de manutenção — DfFormScaffold Mescla.
class MaintenanceFormScreen extends HookConsumerWidget {
  const MaintenanceFormScreen({this.record, super.key});

  final MaintenanceEntity? record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vehicle = ref.watch(activeVehicleProvider).valueOrNull;
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final isEditing = record != null;

    final costController = useTextEditingController(
      text: record != null ? CurrencyFormatter.format(record!.cost) : '',
    );
    final notesController = useTextEditingController(text: record?.notes ?? '');
    final nextKmController = useTextEditingController(
      text: record?.nextDueKm?.toStringAsFixed(0) ?? '',
    );
    final selectedType = useState(record?.type ?? MaintenanceType.oil);
    final serviceDate = useState(record?.serviceDate ?? DateTime.now());
    final nextDueDate = useState<DateTime?>(record?.nextDueDate);
    final mutation = ref.watch(maintenanceControllerProvider);

    Future<void> pickServiceDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: serviceDate.value,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 1)),
        locale: const Locale('pt', 'BR'),
      );
      if (picked != null) serviceDate.value = picked;
    }

    Future<void> pickNextDueDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate:
            nextDueDate.value ?? DateTime.now().add(const Duration(days: 90)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        locale: const Locale('pt', 'BR'),
      );
      if (picked != null) nextDueDate.value = picked;
    }

    Future<void> submit() async {
      if (vehicle == null) return;
      if (!(formKey.currentState?.validate() ?? false)) return;

      final cost = CurrencyFormatter.tryParse(costController.text);
      if (cost == null) return;

      double? nextKm;
      if (nextKmController.text.trim().isNotEmpty) {
        nextKm = double.parse(
          nextKmController.text.trim().replaceAll('.', '').replaceAll(',', '.'),
        );
      }

      final draft = MaintenanceDraft(
        vehicleId: vehicle.id,
        type: selectedType.value,
        cost: cost,
        serviceDate: serviceDate.value,
        notes: notesController.text,
        nextDueKm: nextKm,
        nextDueDate: nextDueDate.value,
      );

      final saved = await ref.read(maintenanceControllerProvider.notifier).save(
            maintenanceId: record?.id,
            draft: draft,
          );
      if (saved != null && context.mounted) context.pop();
    }

    if (vehicle == null) {
      return const DfSubpageScaffold(
        title: 'Manutenção',
        children: [
          DfEmptyState(
            variant: DfEmptyStateVariant.illustrated,
            icon: Icons.directions_car_outlined,
            title: 'Cadastre um veículo primeiro',
            subtitle:
                'Vá em Perfil → Adicionar veículo para registrar manutenções.',
          ),
        ],
      );
    }

    return DfFormScaffold(
      title: isEditing ? 'Editar manutenção' : 'Nova manutenção',
      submitLabel: isEditing ? 'Salvar alterações' : 'Registrar manutenção',
      isLoading: mutation.isLoading,
      onSubmit: submit,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'MANUTENÇÃO',
              style: AppTypography.labelCaps(theme.brightness),
            ),
            const SizedBox(height: 8),
            Text(
              vehicle.displayName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            DfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tipo', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kMaintenanceTypes.map((type) {
                      return DfFilterPill(
                        icon: type.icon,
                        label: type.label,
                        selected: selectedType.value == type,
                        accentColor: AppColors.warningAmber,
                        onSelected: () => selectedType.value = type,
                      );
                    }).toList(growable: false),
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: costController,
                    label: 'Custo (R\$)',
                    hint: 'R\$ 350,00',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.brlAmount,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Data do serviço'),
                    subtitle: Text(
                      DateUtilsDriveFlow.dayMonthYear.format(serviceDate.value),
                    ),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: pickServiceDate,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: nextKmController,
                    label: 'Próxima revisão em km (opcional)',
                    hint: '55000',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Próxima revisão em data (opcional)'),
                    subtitle: Text(
                      nextDueDate.value == null
                          ? 'Não definida'
                          : DateUtilsDriveFlow.dayMonthYear
                              .format(nextDueDate.value!),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (nextDueDate.value != null)
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => nextDueDate.value = null,
                          ),
                        const Icon(Icons.event_outlined),
                      ],
                    ),
                    onTap: pickNextDueDate,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: notesController,
                    label: 'Observação (opcional)',
                    hint: 'Troca de óleo sintético 5W30',
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
          ],
        ),
      ),
    );
  }
}
