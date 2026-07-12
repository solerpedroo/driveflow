import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../shared/widgets/driveflow_gradient_background.dart';
import '../../../../shared/widgets/driveflow_mark.dart';
import '../providers/brand_intro_provider.dart';
import '../widgets/brand_intro.dart';
import '../widgets/splash_story_slides.dart';

/// Splash: intro de marca → storytelling enquanto auth/profile carregam.
class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final introDone = useState(ref.read(brandIntroCompleteProvider));
    final showStory = useState(ref.read(brandIntroCompleteProvider));

    useEffect(() {
      FlutterNativeSplash.remove();
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: kBrandSplashColor,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
      return null;
    }, const []);

    useEffect(() {
      if (!introDone.value) return null;
      SystemChrome.setSystemUIOverlayStyle(
        theme.brightness == Brightness.dark
            ? AppColors.darkOverlay
            : AppColors.lightOverlay,
      );
      return null;
    }, [introDone.value, theme.brightness]);

    void completeIntro() {
      if (introDone.value) return;
      introDone.value = true;
      ref.read(brandIntroCompleteProvider.notifier).state = true;
      // Se ainda estamos no splash (loading), revela a story.
      Future<void>.delayed(DriveFlowMotion.fast, () {
        if (context.mounted) showStory.value = true;
      });
    }

    return AnimatedSwitcher(
      duration: DriveFlowMotion.slow,
      switchInCurve: DriveFlowMotion.enter,
      switchOutCurve: DriveFlowMotion.exit,
      child: !introDone.value
          ? BrandIntro(
              key: const ValueKey('brand-intro'),
              onComplete: completeIntro,
            )
          : DriveFlowGradientBackground(
              key: const ValueKey('splash-story'),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AnimatedOpacity(
                        opacity: showStory.value ? 1 : 0,
                        duration: DriveFlowMotion.normal,
                        child: const SplashStorySlides(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
