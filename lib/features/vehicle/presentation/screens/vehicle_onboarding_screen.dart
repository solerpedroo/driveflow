import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_filter_pill.dart';
import '../../../../shared/widgets/design_system/df_text_field.dart';
import '../../../../shared/widgets/driveflow_gradient_background.dart';
import '../../../authentication/presentation/widgets/auth_editorial_chrome.dart';
import '../../../authentication/presentation/widgets/auth_step_progress.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../providers/vehicle_providers.dart';

enum _VehicleStep {
  brand,
  model,
  year,
  fuel,
  odometer,
  extras,
}

extension on _VehicleStep {
  String get eyebrow => switch (this) {
        _VehicleStep.brand => 'Seu veículo',
        _VehicleStep.model => 'Identidade',
        _VehicleStep.year => 'Detalhes',
        _VehicleStep.fuel => 'Consumo',
        _VehicleStep.odometer => 'Uso atual',
        _VehicleStep.extras => 'Opcional',
      };

  String get headline => switch (this) {
        _VehicleStep.brand => 'Qual a\nmarca?',
        _VehicleStep.model => 'Qual o\nmodelo?',
        _VehicleStep.year => 'De que\nano é?',
        _VehicleStep.fuel => 'Qual\ncombustível?',
        _VehicleStep.odometer => 'Qual a\nquilometragem?',
        _VehicleStep.extras => 'Quer\ndetalhar?',
      };

  String subtitle(bool isTaxi) => switch (this) {
        _VehicleStep.brand => isTaxi
            ? 'Usamos a marca para organizar custos e relatórios do táxi.'
            : 'Usamos a marca para organizar consumo e relatórios.',
        _VehicleStep.model =>
          'Junto com a marca, isso aparece no painel e nos cálculos.',
        _VehicleStep.year =>
          'Ajuda a estimar manutenção e vida útil do veículo.',
        _VehicleStep.fuel =>
          'Define o tipo de abastecimento nos registros de combustível.',
        _VehicleStep.odometer =>
          'Ponto de partida para custo por km e alertas de manutenção.',
        _VehicleStep.extras =>
          'Apelido, placa e consumo médio — você pode pular e completar depois.',
      };

  IconData get icon => switch (this) {
        _VehicleStep.brand => Icons.directions_car_outlined,
        _VehicleStep.model => Icons.car_rental_rounded,
        _VehicleStep.year => Icons.calendar_today_outlined,
        _VehicleStep.fuel => Icons.local_gas_station_outlined,
        _VehicleStep.odometer => Icons.speed_rounded,
        _VehicleStep.extras => Icons.tune_rounded,
      };

  bool get isLast => this == _VehicleStep.extras;
}

/// Primeiro acesso — cadastro de veículo em etapas (padrão Mescla / auth).
class VehicleOnboardingScreen extends HookConsumerWidget {
  const VehicleOnboardingScreen({super.key});

  static const _totalSteps = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isTaxi = ref.watch(isTaxiDriverProvider);

    final formKey = useMemoized(GlobalKey<FormState>.new);
    final brandController = useTextEditingController();
    final modelController = useTextEditingController();
    final yearController = useTextEditingController(
      text: DateTime.now().year.toString(),
    );
    final odometerController = useTextEditingController();
    final nicknameController = useTextEditingController();
    final plateController = useTextEditingController();
    final tankController = useTextEditingController();
    final consumptionController = useTextEditingController();
    final selectedFuel = useState(FuelType.flex);
    final stepIndex = useState(0);

    final mutation = ref.watch(vehicleControllerProvider);
    final isLoading = mutation.isLoading;
    final step = _VehicleStep.values[stepIndex.value];

    final breath = useAnimationController(duration: DriveFlowMotion.pulse);
    useEffect(() {
      breath.repeat(reverse: true);
      return null;
    }, [breath]);

    useEffect(() {
      SystemChrome.setSystemUIOverlayStyle(
        brightness == Brightness.dark
            ? AppColors.darkOverlay
            : AppColors.lightOverlay,
      );
      return null;
    }, [brightness]);

    bool validateCurrentStep() {
      switch (step) {
        case _VehicleStep.brand:
          return Validators.requiredField(
                brandController.text,
                fieldName: 'Marca',
              ) ==
              null;
        case _VehicleStep.model:
          return Validators.requiredField(
                modelController.text,
                fieldName: 'Modelo',
              ) ==
              null;
        case _VehicleStep.year:
          final base = Validators.requiredField(
            yearController.text,
            fieldName: 'Ano',
          );
          if (base != null) return false;
          final year = int.tryParse(yearController.text.trim());
          return year != null && year >= 1980 && year <= 2100;
        case _VehicleStep.fuel:
          return true;
        case _VehicleStep.odometer:
          return Validators.odometer(odometerController.text) == null;
        case _VehicleStep.extras:
          return true;
      }
    }

    Future<void> submit() async {
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
        isDefault: true,
      );

      final saved = await ref.read(vehicleControllerProvider.notifier).save(
            draft: draft,
          );
      if (saved != null && context.mounted) {
        context.go(AppRoutes.home);
      }
    }

    Future<void> goNext() async {
      if (!(formKey.currentState?.validate() ?? false) ||
          !validateCurrentStep()) {
        formKey.currentState?.validate();
        return;
      }
      DfHaptics.light();
      if (step.isLast) {
        await submit();
        return;
      }
      stepIndex.value += 1;
    }

    void goBack() {
      if (stepIndex.value == 0) return;
      DfHaptics.light();
      stepIndex.value -= 1;
    }

    Widget buildStepBody() {
      return switch (step) {
        _VehicleStep.brand => DfTextField(
            controller: brandController,
            label: 'Marca',
            hint: 'Ex.: Toyota',
            autofocus: true,
            textInputAction: TextInputAction.next,
            validator: (v) => Validators.requiredField(v, fieldName: 'Marca'),
            onFieldSubmitted: (_) => goNext(),
          ),
        _VehicleStep.model => DfTextField(
            controller: modelController,
            label: 'Modelo',
            hint: 'Ex.: Corolla',
            autofocus: true,
            textInputAction: TextInputAction.next,
            validator: (v) => Validators.requiredField(v, fieldName: 'Modelo'),
            onFieldSubmitted: (_) => goNext(),
          ),
        _VehicleStep.year => DfTextField(
            controller: yearController,
            label: 'Ano',
            hint: '2022',
            autofocus: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (v) {
              final base = Validators.requiredField(v, fieldName: 'Ano');
              if (base != null) return base;
              final year = int.tryParse(v!.trim());
              if (year == null || year < 1980 || year > 2100) {
                return 'Ano inválido';
              }
              return null;
            },
            onFieldSubmitted: (_) => goNext(),
          ),
        _VehicleStep.fuel => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Combustível', style: theme.textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kFuelTypes.map((fuel) {
                  final selected = selectedFuel.value == fuel;
                  return DfFilterPill(
                    label: fuel.label,
                    selected: selected,
                    onSelected: () {
                      DfHaptics.selection();
                      selectedFuel.value = fuel;
                    },
                  );
                }).toList(growable: false),
              ),
            ],
          ),
        _VehicleStep.odometer => DfTextField(
            controller: odometerController,
            label: 'Quilometragem atual',
            hint: '45000',
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            validator: Validators.odometer,
            onFieldSubmitted: (_) => goNext(),
          ),
        _VehicleStep.extras => Column(
            children: [
              DfTextField(
                controller: nicknameController,
                label: 'Apelido (opcional)',
                hint: 'Ex.: Carro do trabalho',
                autofocus: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.lg),
              DfTextField(
                controller: plateController,
                label: 'Placa (opcional)',
                hint: 'ABC1D23',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.lg),
              DfTextField(
                controller: tankController,
                label: 'Tanque em litros (opcional)',
                hint: '50',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.lg),
              DfTextField(
                controller: consumptionController,
                label: 'Consumo médio km/L (opcional)',
                hint: '12.5',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
      };
    }

    return DriveFlowGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(child: AuthAtmosphereBlooms(animation: breath)),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
                  AppSpacing.screenHorizontal,
                  AppSpacing.xxl,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthFlowTopBar(
                        onBack: stepIndex.value == 0 ? null : goBack,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AuthStepProgress(
                        currentStep: stepIndex.value,
                        totalSteps: _totalSteps,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AnimatedSwitcher(
                        duration: DriveFlowMotion.normal,
                        switchInCurve: DriveFlowMotion.enter,
                        switchOutCurve: DriveFlowMotion.exit,
                        child: AuthEditorialCopy(
                          key: ValueKey(step),
                          eyebrow: step.eyebrow,
                          headline: step.headline,
                          subtitle: step.subtitle(isTaxi),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      DfCard(
                        variant: DfCardVariant.glass,
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthStepIcon(icon: step.icon),
                            const SizedBox(height: AppSpacing.lg),
                            AnimatedSwitcher(
                              duration: DriveFlowMotion.normal,
                              switchInCurve: DriveFlowMotion.enter,
                              switchOutCurve: DriveFlowMotion.exit,
                              transitionBuilder: (child, animation) {
                                final offset = Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(animation);
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: offset,
                                    child: child,
                                  ),
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey(step),
                                child: buildStepBody(),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            DfButton(
                              label: step.isLast
                                  ? 'Entrar no painel'
                                  : 'Continuar',
                              icon: Icons.arrow_forward_rounded,
                              trailingIcon: true,
                              variant: DfButtonVariant.gradient,
                              isLoading: isLoading && step.isLast,
                              onPressed: isLoading ? null : goNext,
                            ),
                            if (step == _VehicleStep.extras) ...[
                              const SizedBox(height: AppSpacing.sm),
                              DfButton(
                                label: 'Pular e entrar',
                                variant: DfButtonVariant.tonal,
                                onPressed: isLoading ? null : submit,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (stepIndex.value > 0) ...[
                        const SizedBox(height: AppSpacing.sm),
                        DfButton(
                          label: 'Voltar',
                          icon: Icons.arrow_back_rounded,
                          variant: DfButtonVariant.tonal,
                          onPressed: isLoading ? null : goBack,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double? _parseOptionalDouble(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  return double.tryParse(trimmed.replaceAll(',', '.'));
}

double _parseRequiredDouble(String raw) {
  return double.parse(raw.trim().replaceAll(',', '.'));
}
