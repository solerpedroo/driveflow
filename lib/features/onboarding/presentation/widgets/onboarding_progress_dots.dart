import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';

/// Indicador de progresso do onboarding — dots animados estilo Mescla.
class OnboardingProgressDots extends StatelessWidget {
  const OnboardingProgressDots({
    required this.count,
    required this.index,
    super.key,
  });

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: DriveFlowMotion.fast,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: active
                ? AppColors.brandBlue
                : AppColors.brandBlue.withValues(alpha: 0.22),
          ),
        );
      }),
    );
  }
}
