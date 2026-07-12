import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/driver_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/driveflow_gradient_background.dart';
import '../../../authentication/presentation/widgets/auth_editorial_chrome.dart';
import '../../../authentication/presentation/widgets/auth_step_progress.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../widgets/driver_type_picker.dart';

/// Escolha de perfil — mesma composição editorial do cadastro.
class DriverTypeGateScreen extends HookConsumerWidget {
  const DriverTypeGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final selected = useState(DriverType.rideShare);
    final mutation = ref.watch(profileControllerProvider);
    final isLoading = mutation.isLoading;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthFlowTopBar(),
                    const SizedBox(height: AppSpacing.xl),
                    const AuthEditorialCopy(
                      eyebrow: 'Comece pelo perfil',
                      headline: 'Como você\ntrabalha?',
                      subtitle:
                          'Personalizamos o painel, os ganhos e o onboarding para a sua rotina.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DfCard(
                      variant: DfCardVariant.glass,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const AuthStepIcon(icon: Icons.work_outline_rounded),
                          const SizedBox(height: AppSpacing.lg),
                          DriverTypePicker(
                            selected: selected.value,
                            showHeader: false,
                            onChanged: (type) => selected.value = type,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          DfButton(
                            label: 'Continuar',
                            icon: Icons.arrow_forward_rounded,
                            trailingIcon: true,
                            variant: DfButtonVariant.gradient,
                            isLoading: isLoading,
                            onPressed: isLoading ? null : submit,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
