import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Progresso de cadastro em etapas — padrão Mescla Invest (barra + chip N/total).
class AuthStepProgress extends StatelessWidget {
  const AuthStepProgress({
    required this.currentStep,
    required this.totalSteps,
    super.key,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final clamped = currentStep.clamp(0, totalSteps - 1);
    final progress = (clamped + 1) / totalSteps;
    final label = '${clamped + 1}/$totalSteps';

    return Semantics(
      label: 'Etapa ${clamped + 1} de $totalSteps',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: DriveFlowMotion.normal,
                    curve: DriveFlowMotion.standard,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        backgroundColor: AppColors.mutedSurface(theme),
                        color: AppColors.brandBlue,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              AnimatedSwitcher(
                duration: DriveFlowMotion.fast,
                child: Container(
                  key: ValueKey(label),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs + 1,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.brandBlue.withValues(alpha: 0.16),
                        AppColors.brandGlow.withValues(alpha: 0.22),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: AppColors.brandBlue.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Text(
                    label,
                    style: AppTypography.iosFootnote(brightness).copyWith(
                      color: AppColors.brandBlue,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Etapa ${clamped + 1} de $totalSteps',
            style: AppTypography.labelCaps(brightness),
          ),
        ],
      ),
    );
  }
}

/// Ícone circular de etapa — âncora visual suave no card do formulário.
class AuthStepIcon extends StatelessWidget {
  const AuthStepIcon({
    required this.icon,
    super.key,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.brandBlue.withValues(alpha: 0.18),
            AppColors.brandGlow.withValues(alpha: 0.35),
          ],
        ),
        border: Border.all(
          color: AppColors.brandBlue.withValues(alpha: 0.20),
        ),
      ),
      child: Icon(icon, color: AppColors.brandBlue, size: 26),
    );
  }
}
