import 'package:flutter/material.dart';

import '../../../../core/constants/product_story.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/driveflow_brand_logo.dart';

/// Carrossel de valor no splash — vende o produto antes do login.
class SplashStorySlides extends StatefulWidget {
  const SplashStorySlides({super.key});

  @override
  State<SplashStorySlides> createState() => _SplashStorySlidesState();
}

class _SplashStorySlidesState extends State<SplashStorySlides> {
  final _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slides = ProductStory.splashSlides;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const DriveFlowBrandLogo(size: LogoSize.medium, showTagline: false),
        const SizedBox(height: AppSpacing.xxl),
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            itemCount: slides.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final slide = slides[i];
              return AnimatedSwitcher(
                duration: DriveFlowMotion.normal,
                child: Column(
                  key: ValueKey(i),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      slide.headline,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      slide.subtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryLabel(theme),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(slides.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: DriveFlowMotion.fast,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: active
                    ? AppColors.skyBlue
                    : AppColors.skyBlue.withValues(alpha: 0.25),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
