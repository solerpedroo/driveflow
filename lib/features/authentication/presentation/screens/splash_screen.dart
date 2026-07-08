import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/driveflow_brand_logo.dart';
import '../../../../shared/widgets/driveflow_gradient_background.dart';

/// Splash com branding — aguarda resolução de auth via redirect do router.
class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1400),
    );
    final fade = CurvedAnimation(parent: controller, curve: Curves.easeOut);

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
          child: FadeTransition(
            opacity: fade,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DriveFlowBrandLogo(size: LogoSize.large),
                const SizedBox(height: 32),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
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
