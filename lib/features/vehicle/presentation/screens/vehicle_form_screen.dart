import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failure_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/design_system/df_text_field.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../providers/vehicle_providers.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_filter_pill.dart';
import '../../../../shared/widgets/design_system/df_form_scaffold.dart';

/// Formulário reutilizável de veículo (onboarding + edição).
class VehicleFormScreen extends HookConsumerWidget {
  const VehicleFormScreen({
    this.vehicle,
    this.title = 'Seu veículo',
    this.subtitle =
        'Cadastre o carro que você usa nas corridas. Esses dados alimentam consumo e custos.',
    this.submitLabel = 'Salvar veículo',
    this.markAsDefault = false,
    this.onSaved,
    this.embedded = false,
    super.key,
  });

  final VehicleEntity? vehicle;
  final String title;
  final String subtitle;
  final String submitLabel;
  final bool markAsDefault;
  final VoidCallback? onSaved;

  /// Quando `true`, renderiza só o corpo do formulário (ex.: onboarding).
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final brandController = useTextEditingController(text: vehicle?.brand ?? '');
    final modelController = useTextEditingController(text: vehicle?.model ?? '');
    final nicknameController =
        useTextEditingController(text: vehicle?.nickname ?? '');
    final yearController = useTextEditingController(
      text: vehicle?.year.toString() ?? DateTime.now().year.toString(),
    );
    final plateController = useTextEditingController(text: vehicle?.plate ?? '');
    final tankController = useTextEditingController(
      text: vehicle?.tankLiters?.toString() ?? '',
    );
    final consumptionController = useTextEditingController(
      text: vehicle?.avgConsumptionKmPerLiter?.toString() ?? '',
    );
    final odometerController = useTextEditingController(
      text: vehicle?.odometerKm.toStringAsFixed(0) ?? '',
    );
    final selectedFuel = useState(vehicle?.fuel ?? FuelType.flex);
    final isDefault = useState(vehicle?.isDefault ?? markAsDefault);
    final mutation = ref.watch(vehicleControllerProvider);
    final vehicleCount =
        ref.watch(vehiclesListProvider).valueOrNull?.length ?? 0;

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      final year = int.parse(yearController.text.trim());
      final draft = VehicleDraft(
        brand: brandController.text,
        model: modelController.text,
        year: year,
        nickname: nicknameController.text,
        plate: plateController.text,
        fuel: selectedFuel.value,
        tankLiters: _parseOptionalDouble(tankController.text),
        avgConsumptionKmPerLiter:
            _parseOptionalDouble(consumptionController.text),
        odometerKm: _parseRequiredDouble(odometerController.text),
        isDefault: isDefault.value,
      );

      final saved = await ref.read(vehicleControllerProvider.notifier).save(
            vehicleId: vehicle?.id,
            draft: draft,
          );
      if (saved != null && context.mounted) {
        onSaved?.call();
      }
    }

    final formBody = Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (embedded) ...[
            Text(title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
          ] else ...[
            Text(
              'VEÍCULO',
              style: AppTypography.labelCaps(theme.brightness),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryLabel(theme),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          DfCard(
            child: Column(
              children: [
                DfTextField(
                  controller: brandController,
                  label: 'Marca',
                  hint: 'Ex.: Toyota',
                  validator: (v) =>
                      Validators.requiredField(v, fieldName: 'Marca'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                DfTextField(
                  controller: modelController,
                  label: 'Modelo',
                  hint: 'Ex.: Corolla',
                  validator: (v) =>
                      Validators.requiredField(v, fieldName: 'Modelo'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                DfTextField(
                  controller: yearController,
                  label: 'Ano',
                  hint: '2022',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final base =
                        Validators.requiredField(v, fieldName: 'Ano');
                    if (base != null) return base;
                    final year = int.tryParse(v!.trim());
                    if (year == null || year < 1980 || year > 2100) {
                      return 'Ano inválido';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                DfTextField(
                  controller: nicknameController,
                  label: 'Apelido (opcional)',
                  hint: 'Ex.: Carro do trabalho',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                DfTextField(
                  controller: plateController,
                  label: 'Placa (opcional)',
                  hint: 'ABC1D23',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Combustível', style: theme.textTheme.labelLarge),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kFuelTypes.map((fuel) {
                    final selected = selectedFuel.value == fuel;
                    return DfFilterPill(
                      label: fuel.label,
                      selected: selected,
                      onSelected: () => selectedFuel.value = fuel,
                    );
                  }).toList(growable: false),
                ),
                const SizedBox(height: 12),
                DfTextField(
                  controller: tankController,
                  label: 'Tanque (litros, opcional)',
                  hint: '50',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                DfTextField(
                  controller: consumptionController,
                  label: 'Consumo médio km/L (opcional)',
                  hint: '12.5',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                DfTextField(
                  controller: odometerController,
                  label: 'Quilometragem atual',
                  hint: '45000',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => Validators.odometer(
                    v,
                    previous: vehicle?.odometerKm,
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => submit(),
                ),
                if (vehicleCount > 0 || vehicle != null) ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Veículo padrão'),
                    subtitle: const Text(
                      'Usado como fallback e para novos registros.',
                    ),
                    value: isDefault.value,
                    onChanged: (value) => isDefault.value = value,
                  ),
                ],
              ],
            ),
          ),
          if (mutation.hasError) ...[
            const SizedBox(height: 12),
            Text(
              FailureMessage.forObject(mutation.error),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          if (embedded) ...[
            const SizedBox(height: 20),
            DfButton(
              label: submitLabel,
              isLoading: mutation.isLoading,
              onPressed: submit,
            ),
          ],
        ],
      ),
    );

    if (embedded) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: formBody,
      );
    }

    return DfFormScaffold(
      title: title,
      submitLabel: submitLabel,
      isLoading: mutation.isLoading,
      onSubmit: submit,
      child: formBody,
    );
  }

  static double? _parseOptionalDouble(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.parse(trimmed.replaceAll(',', '.'));
  }

  static double _parseRequiredDouble(String value) {
    return double.parse(
      value.trim().replaceAll('.', '').replaceAll(',', '.'),
    );
  }
}
