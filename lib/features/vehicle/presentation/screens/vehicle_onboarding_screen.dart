import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/driveflow_brand_logo.dart';
import '../../../../shared/widgets/driveflow_gradient_background.dart';
import 'vehicle_form_screen.dart';

/// Onboarding obrigatório quando o usuário não tem veículo cadastrado.
class VehicleOnboardingScreen extends ConsumerWidget {
  const VehicleOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DriveFlowGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: DriveFlowBrandLogo(size: LogoSize.medium),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text(
                  'Antes de começar',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.electricTeal,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: VehicleFormScreen(
                  title: 'Cadastre seu veículo',
                  subtitle:
                      'Precisamos dos dados básicos do carro para calcular consumo, custo por km e relatórios.',
                  submitLabel: 'Continuar para o app',
                  onSaved: () {
                    // Router redirect leva ao shell quando hasVehicleProvider = true.
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
