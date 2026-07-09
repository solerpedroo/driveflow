import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/password_strength.dart';

/// Checklist animado de requisitos de senha — feedback em tempo real.
class DfPasswordChecklist extends StatelessWidget {
  const DfPasswordChecklist({
    required this.password,
    super.key,
  });

  final String password;

  static const _requirements = <_Requirement>[
    _Requirement(
      label: 'Mínimo 8 caracteres',
      check: PasswordStrength.hasMinLength,
    ),
    _Requirement(
      label: 'Uma letra maiúscula',
      check: PasswordStrength.hasUppercase,
    ),
    _Requirement(
      label: 'Uma letra minúscula',
      check: PasswordStrength.hasLowercase,
    ),
    _Requirement(
      label: 'Um número',
      check: PasswordStrength.hasDigit,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = PasswordStrength.score(password);
    final progress = password.isEmpty ? 0.0 : score / 4.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: AppRadius.smAll,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: progress),
            duration: DriveFlowMotion.fast,
            curve: DriveFlowMotion.standard,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: password.isEmpty ? null : value,
                minHeight: 4,
                backgroundColor:
                    AppColors.mutedSurface(theme).withValues(alpha: 0.6),
                color: _strengthColor(score),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ..._requirements.map(
          (req) => _ChecklistRow(
            key: ValueKey('${req.label}-$password'),
            label: req.label,
            met: req.check(password),
          ),
        ),
      ],
    );
  }

  static Color _strengthColor(int score) {
    return switch (score) {
      <= 1 => AppSemanticColors.error,
      2 => AppSemanticColors.warning,
      3 => AppColors.skyBlue,
      _ => AppSemanticColors.success,
    };
  }
}

class _Requirement {
  const _Requirement({required this.label, required this.check});

  final String label;
  final bool Function(String) check;
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.label,
    required this.met,
    super.key,
  });

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = met
        ? AppSemanticColors.success
        : AppColors.secondaryLabel(theme);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AnimatedSwitcher(
        duration: DriveFlowMotion.fast,
        switchInCurve: DriveFlowMotion.enter,
        switchOutCurve: DriveFlowMotion.exit,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-0.05, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: Row(
          key: ValueKey('$label-$met'),
          children: [
            AnimatedContainer(
              duration: DriveFlowMotion.fast,
              curve: DriveFlowMotion.standard,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: met
                    ? AppSemanticColors.success.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: AppRadius.smAll,
                border: Border.all(
                  color: met
                      ? AppSemanticColors.success
                      : AppColors.secondaryLabel(theme).withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Icon(
                met ? Icons.check_rounded : Icons.circle_outlined,
                size: met ? 16 : 10,
                color: color,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: DriveFlowMotion.fast,
                style: theme.textTheme.bodySmall!.copyWith(
                  color: color,
                  fontWeight: met ? FontWeight.w600 : FontWeight.w400,
                ),
                child: Text(label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
