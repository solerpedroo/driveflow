import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/driveflow_gradient_background.dart';
import '../../../authentication/presentation/widgets/auth_editorial_chrome.dart';
import '../../../authentication/presentation/widgets/auth_step_progress.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../domain/onboarding_catalog.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/onboarding_slide_view.dart';

/// Onboarding de boas-vindas — composição editorial alinhada ao auth.
class WelcomeOnboardingScreen extends HookConsumerWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final driverType = ref.watch(driverTypeProvider);
    final slides = OnboardingCatalog.slidesFor(driverType);
    final pageController = usePageController();
    final pageIndex = useState(0);
    final mutation = ref.watch(profileControllerProvider);
    final isLoading = mutation.isLoading;
    final isLast = pageIndex.value >= slides.length - 1;

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

    Future<void> finish() async {
      final updated = await ref
          .read(profileControllerProvider.notifier)
          .completeWelcomeOnboarding();
      if (updated != null && context.mounted) {
        context.go(AppRoutes.vehicleOnboarding);
      }
    }

    void onPrimaryAction() {
      if (!isLast) {
        pageController.nextPage(
          duration: DriveFlowMotion.normal,
          curve: DriveFlowMotion.standard,
        );
        return;
      }
      finish();
    }

    final slide = slides[pageIndex.value];

    return DriveFlowGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(child: AuthAtmosphereBlooms(animation: breath)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
                  AppSpacing.screenHorizontal,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthFlowTopBar(
                      onBack: pageIndex.value == 0
                          ? null
                          : () => pageController.previousPage(
                                duration: DriveFlowMotion.fast,
                                curve: DriveFlowMotion.exit,
                              ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AuthStepProgress(
                      currentStep: pageIndex.value,
                      totalSteps: slides.length,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AnimatedSwitcher(
                      duration: DriveFlowMotion.normal,
                      switchInCurve: DriveFlowMotion.enter,
                      switchOutCurve: DriveFlowMotion.exit,
                      child: AuthEditorialCopy(
                        key: ValueKey(pageIndex.value),
                        eyebrow: driverType.isTaxi
                            ? 'Feito para taxista'
                            : 'Bem-vindo ao DriveFlow',
                        headline: slide.title.contains('\n')
                            ? slide.title
                            : _twoLineHeadline(slide.title),
                        subtitle: slide.body,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Expanded(
                      child: DfCard(
                        variant: DfCardVariant.glass,
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          children: [
                            Expanded(
                              child: PageView.builder(
                                controller: pageController,
                                itemCount: slides.length,
                                onPageChanged: (index) =>
                                    pageIndex.value = index,
                                itemBuilder: (context, index) {
                                  return OnboardingSlideView(
                                    slide: slides[index],
                                    compact: true,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            DfButton(
                              label: isLast ? 'Cadastrar veículo' : 'Continuar',
                              icon: Icons.arrow_forward_rounded,
                              trailingIcon: true,
                              variant: DfButtonVariant.gradient,
                              isLoading: isLoading,
                              onPressed: isLoading ? null : onPrimaryAction,
                            ),
                            if (pageIndex.value > 0) ...[
                              const SizedBox(height: AppSpacing.sm),
                              DfButton(
                                label: 'Voltar',
                                icon: Icons.arrow_back_rounded,
                                variant: DfButtonVariant.tonal,
                                onPressed: isLoading
                                    ? null
                                    : () => pageController.previousPage(
                                          duration: DriveFlowMotion.fast,
                                          curve: DriveFlowMotion.exit,
                                        ),
                              ),
                            ],
                          ],
                        ),
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

  static String _twoLineHeadline(String title) {
    final words = title.trim().split(RegExp(r'\s+'));
    if (words.length < 3) return title;
    final mid = (words.length / 2).ceil();
    return '${words.take(mid).join(' ')}\n${words.skip(mid).join(' ')}';
  }
}
