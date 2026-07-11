import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../domain/onboarding_catalog.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/driveflow_brand_logo.dart';
import '../../../../shared/widgets/driveflow_gradient_background.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/onboarding_progress_dots.dart';
import '../widgets/onboarding_slide_view.dart';

/// Onboarding editorial de boas-vindas — padrão Mescla Invest.
class WelcomeOnboardingScreen extends HookConsumerWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverType = ref.watch(driverTypeProvider);
    final slides = OnboardingCatalog.slidesFor(driverType);
    final pageController = usePageController();
    final pageIndex = useState(0);
    final mutation = ref.watch(profileControllerProvider);
    final isLoading = mutation.isLoading;

    Future<void> finish() async {
      final updated = await ref
          .read(profileControllerProvider.notifier)
          .completeWelcomeOnboarding();
      if (updated != null && context.mounted) {
        context.go(AppRoutes.vehicleOnboarding);
      }
    }

    void onPrimaryAction() {
      if (pageIndex.value < slides.length - 1) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
        return;
      }
      finish();
    }

    return DriveFlowGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
              AppSpacing.screenHorizontal,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DriveFlowBrandLogo(
                  size: LogoSize.small,
                  showTagline: false,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  driverType.isTaxi
                      ? 'Bem-vindo, taxista'
                      : 'Bem-vindo ao DriveFlow',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: slides.length,
                    onPageChanged: (index) => pageIndex.value = index,
                    itemBuilder: (context, index) {
                      return OnboardingSlideView(slide: slides[index]);
                    },
                  ),
                ),
                OnboardingProgressDots(
                  count: slides.length,
                  index: pageIndex.value,
                ),
                const SizedBox(height: AppSpacing.xl),
                DfButton(
                  label: pageIndex.value == slides.length - 1
                      ? 'Começar a usar'
                      : 'Continuar',
                  icon: pageIndex.value == slides.length - 1
                      ? Icons.rocket_launch_rounded
                      : Icons.arrow_forward_rounded,
                  variant: DfButtonVariant.gradient,
                  isLoading: isLoading,
                  onPressed: isLoading ? null : onPrimaryAction,
                ),
                if (pageIndex.value > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  DfButton(
                    label: 'Voltar',
                    variant: DfButtonVariant.tonal,
                    onPressed: isLoading
                        ? null
                        : () => pageController.previousPage(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOutCubic,
                            ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
