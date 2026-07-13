import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Badge de aderência ao plano de turno.
class ShiftAdherenceBadge extends StatelessWidget {
  const ShiftAdherenceBadge({
    required this.score,
    super.key,
  });

  final double score;

  Color _color(Brightness brightness) {
    if (score >= 80) return AppColors.profitGreen;
    if (score >= 50) return AppColors.warningAmber;
    return AppColors.expenseCoral;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = _color(brightness);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        '${score.round()}% plano',
        style: AppTypography.iosFootnote(brightness).copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
