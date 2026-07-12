import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/design_system/df_text_field.dart';
import '../../../../shared/widgets/platform_brand_icon.dart';
import '../../domain/entities/earning_entity.dart';
import '../providers/earnings_providers.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_form_scaffold.dart';
import '../../../../shared/widgets/design_system/df_filter_pill.dart';

/// Formulário de criação/edição de ganho.
class EarningFormScreen extends HookConsumerWidget {
  const EarningFormScreen({this.earning, super.key});

  final EarningEntity? earning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final isEditing = earning != null;

    final amountController = useTextEditingController(
      text: earning != null ? CurrencyFormatter.format(earning!.amount) : '',
    );
    final ridesController = useTextEditingController(
      text: earning?.rides.toString() ?? '0',
    );
    final hoursController = useTextEditingController(
      text: earning?.workedHours.toString() ?? '0',
    );
    final noteController = useTextEditingController(text: earning?.note ?? '');
    final selectedPlatform = useState(
      earning?.platform ??
          (ref.read(driverTypeProvider).isTaxi
              ? RidePlatform.taximeter
              : RidePlatform.uber),
    );
    final platforms = ridePlatformsFor(ref.watch(driverTypeProvider));
    final selectedDate = useState(earning?.date ?? DateTime.now());
    final mutation = ref.watch(earningsControllerProvider);

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

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      final amount = CurrencyFormatter.tryParse(amountController.text);
      if (amount == null) return;

      final scopedVehicleId = ref.read(scopedVehicleIdProvider);
      final draft = EarningDraft(
        platform: selectedPlatform.value,
        amount: amount,
        rides: int.parse(ridesController.text.trim()),
        workedHours: double.parse(hoursController.text.trim().replaceAll(',', '.')),
        date: selectedDate.value,
        note: noteController.text,
        vehicleId: scopedVehicleId ?? ref.read(activeVehicleProvider).valueOrNull?.id,
      );

      final saved = await ref.read(earningsControllerProvider.notifier).save(
            earningId: earning?.id,
            draft: draft,
          );
      if (saved != null && context.mounted) context.pop();
    }

    return DfFormScaffold(
      title: isEditing ? 'Editar ganho' : 'Novo ganho',
      submitLabel: isEditing ? 'Salvar alterações' : 'Registrar ganho',
      isLoading: mutation.isLoading,
      onSubmit: submit,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.watch(isTaxiDriverProvider) ? 'Canal' : 'Plataforma',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: platforms.map((platform) {
                      return DfFilterPill(
                        label: platform.label,
                        selected: selectedPlatform.value == platform,
                        leading: PlatformBrandIcon.hasBrandAsset(platform)
                            ? PlatformBrandIcon(
                                platform: platform,
                                size: 20,
                                borderRadius: 6,
                              )
                            : null,
                        onSelected: () =>
                            selectedPlatform.value = platform,
                      );
                    }).toList(growable: false),
                  ),
                  const SizedBox(height: 16),
                  DfTextField(
                    controller: amountController,
                    label: 'Valor (R\$)',
                    hint: 'R\$ 248,50',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.brlAmount,
                  ),
                  const SizedBox(height: 12),
                  DfTextField(
                    controller: ridesController,
                    label: ref.watch(isTaxiDriverProvider)
                        ? 'Corridas / viagens'
                        : 'Corridas',
                    hint: '12',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Informe a quantidade';
                      }
                      final n = int.tryParse(v.trim());
                      if (n == null || n < 0) return 'Quantidade inválida';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DfTextField(
                    controller: hoursController,
                    label: 'Horas trabalhadas',
                    hint: '6.5',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Informe as horas';
                      }
                      final n =
                          double.tryParse(v.trim().replaceAll(',', '.'));
                      if (n == null || n < 0) return 'Horas inválidas';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Data'),
                    subtitle: Text(
                      DateUtilsDriveFlow.dayMonthYear
                          .format(selectedDate.value),
                    ),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: pickDate,
                  ),
                  const SizedBox(height: 12),
                  DfTextField(
                    controller: noteController,
                    label: 'Observação (opcional)',
                    hint: 'Turno noturno, bônus...',
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
