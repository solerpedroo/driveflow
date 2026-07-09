import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/driveflow_gradient_background.dart';
import '../widgets/splash_story_slides.dart';

/// Splash com storytelling — vende valor antes do redirect de auth.
class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    useEffect(() {
      SystemChrome.setSystemUIOverlayStyle(
        theme.brightness == Brightness.dark
            ? AppColors.darkOverlay
            : AppColors.lightOverlay,
      );
      return null;
    }, [theme.brightness]);

    return DriveFlowGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const SplashStorySlides(),
            ),
          ),
        ),
      ),
    );
  }
}
