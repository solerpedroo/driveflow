import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/driveflow_brand_logo.dart';
import '../../../../shared/widgets/driveflow_gradient_background.dart';

/// Splash com branding animado — aguarda resolução de auth via redirect do router.
class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = useAnimationController(
      duration: DriveFlowMotion.slow,
    );
    final curved = useMemoized(
      () => CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ),
      [controller],
    );

    useEffect(() {
      SystemChrome.setSystemUIOverlayStyle(
        theme.brightness == Brightness.dark
            ? AppColors.darkOverlay
            : AppColors.lightOverlay,
      );
      controller.forward();
      return null;
    }, []);

    return DriveFlowGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: AnimatedBuilder(
            animation: curved,
            builder: (context, child) {
              return Opacity(
                opacity: curved.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.88 + curved.value * 0.12,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DriveFlowBrandLogo(size: LogoSize.large),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Preparando seu cockpit…',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
