import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failure_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/design_system/df_text_field.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../domain/entities/fuel_log_entity.dart';
import '../providers/fuel_providers.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_filter_pill.dart';
import '../../../../shared/widgets/design_system/df_form_scaffold.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';

/// Formulário de registro de abastecimento — DfFormScaffold Mescla.
class FuelLogScreen extends HookConsumerWidget {
  const FuelLogScreen({this.fuelLog, super.key});

  final FuelLogEntity? fuelLog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vehicle = ref.watch(activeVehicleProvider).valueOrNull;
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final isEditing = fuelLog != null;

    final stationController =
        useTextEditingController(text: fuelLog?.station ?? '');
    final priceController = useTextEditingController(
      text: fuelLog != null
          ? fuelLog!.pricePerLiter.toStringAsFixed(3)
          : '',
    );
    final litersController = useTextEditingController(
      text: fuelLog != null ? fuelLog!.liters.toStringAsFixed(2) : '',
    );
    final totalController = useTextEditingController(
      text: fuelLog != null ? CurrencyFormatter.format(fuelLog!.totalAmount) : '',
    );
    final odometerController = useTextEditingController(
      text: fuelLog?.odometerKm.toStringAsFixed(0) ??
          vehicle?.odometerKm.toStringAsFixed(0) ??
          '',
    );
    final selectedFuel =
        useState(fuelLog?.fuelType ?? vehicle?.fuel ?? FuelType.flex);
    final mutation = ref.watch(fuelControllerProvider);

    void syncTotal() {
      final price = double.tryParse(priceController.text.replaceAll(',', '.'));
      final liters =
          double.tryParse(litersController.text.replaceAll(',', '.'));
      if (price != null && liters != null) {
        totalController.text = CurrencyFormatter.format(price * liters);
      }
    }

    useEffect(() {
      priceController.addListener(syncTotal);
      litersController.addListener(syncTotal);
      return () {
        priceController.removeListener(syncTotal);
        litersController.removeListener(syncTotal);
      };
    }, [priceController, litersController]);

    Future<void> submit() async {
      if (vehicle == null) return;
      if (!(formKey.currentState?.validate() ?? false)) return;

      final price =
          double.parse(priceController.text.trim().replaceAll(',', '.'));
      final liters =
          double.parse(litersController.text.trim().replaceAll(',', '.'));
      final total =
          CurrencyFormatter.tryParse(totalController.text) ?? price * liters;
      final odometer = double.parse(
        odometerController.text.trim().replaceAll('.', '').replaceAll(',', '.'),
      );

      final draft = FuelLogDraft(
        vehicleId: vehicle.id,
        fuelType: selectedFuel.value,
        pricePerLiter: price,
        liters: liters,
        totalAmount: total,
        odometerKm: odometer,
        station: stationController.text,
      );

      final saved = await ref.read(fuelControllerProvider.notifier).save(
            fuelLogId: fuelLog?.id,
            draft: draft,
          );
      if (saved != null && context.mounted) context.pop();
    }

    if (vehicle == null) {
      return const DfSubpageScaffold(
        title: 'Abastecimento',
        children: [
          DfEmptyState(
            variant: DfEmptyStateVariant.illustrated,
            icon: Icons.directions_car_outlined,
            title: 'Cadastre um veículo primeiro',
            subtitle:
                'Vá em Perfil → Adicionar veículo para registrar abastecimentos.',
          ),
        ],
      );
    }

    return DfFormScaffold(
      title: isEditing ? 'Editar abastecimento' : 'Novo abastecimento',
      submitLabel:
          isEditing ? 'Salvar alterações' : 'Registrar abastecimento',
      isLoading: mutation.isLoading,
      onSubmit: submit,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ABASTECIMENTO',
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
                  DfTextField(
                    controller: stationController,
                    label: 'Posto (opcional)',
                    hint: 'Shell, Ipiranga...',
                  ),
                  const SizedBox(height: 12),
                  Text('Combustível', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kFuelTypes.map((fuel) {
                      return DfFilterPill(
                        label: fuel.label,
                        selected: selectedFuel.value == fuel,
                        onSelected: () => selectedFuel.value = fuel,
                      );
                    }).toList(growable: false),
                  ),
                  const SizedBox(height: 12),
                  DfTextField(
                    controller: priceController,
                    label: 'Preço por litro (R\$)',
                    hint: '5.89',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) =>
                        Validators.positiveNumber(v, fieldName: 'Preço'),
                  ),
                  const SizedBox(height: 12),
                  DfTextField(
                    controller: litersController,
                    label: 'Litros',
                    hint: '42.5',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) =>
                        Validators.positiveNumber(v, fieldName: 'Litros'),
                  ),
                  const SizedBox(height: 12),
                  DfTextField(
                    controller: totalController,
                    label: 'Valor total (R\$)',
                    hint: 'R\$ 250,00',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.brlAmount,
                  ),
                  const SizedBox(height: 12),
                  DfTextField(
                    controller: odometerController,
                    label: 'Odômetro (km)',
                    hint: '45000',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (isEditing) {
                        return Validators.positiveNumber(
                          v,
                          fieldName: 'Odômetro',
                        );
                      }
                      return Validators.odometer(
                        v,
                        previous: vehicle.odometerKm,
                      );
                    },
                  ),
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
          ],
        ),
      ),
    );
  }
}
