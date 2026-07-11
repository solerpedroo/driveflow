import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/driver_type.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/driveflow_brand_logo.dart';
import '../../../../shared/widgets/driveflow_gradient_background.dart';
import '../widgets/driver_type_picker.dart';

/// Escolha de perfil para usuários OAuth sem tipo definido.
class DriverTypeGateScreen extends HookConsumerWidget {
  const DriverTypeGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = useState(DriverType.rideShare);
    final mutation = ref.watch(profileControllerProvider);
    final isLoading = mutation.isLoading;

    Future<void> submit() async {
      final updated = await ref
          .read(profileControllerProvider.notifier)
          .updateDriverType(selected.value);
      if (updated != null && context.mounted) {
        context.go(AppRoutes.welcomeOnboarding);
      }
    }

    return DriveFlowGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
              AppSpacing.screenHorizontal,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DriveFlowBrandLogo(
                  size: LogoSize.small,
                  showTagline: false,
                ),
                const SizedBox(height: AppSpacing.xxl),
                DriverTypePicker(
                  selected: selected.value,
                  onChanged: (type) => selected.value = type,
                ),
                const SizedBox(height: AppSpacing.xxl),
                DfButton(
                  label: 'Continuar',
                  icon: Icons.arrow_forward_rounded,
                  variant: DfButtonVariant.gradient,
                  isLoading: isLoading,
                  onPressed: isLoading ? null : submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
