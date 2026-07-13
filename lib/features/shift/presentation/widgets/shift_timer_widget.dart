import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Cronômetro do turno ativo (HH:MM:SS).
class ShiftTimerWidget extends StatelessWidget {
  const ShiftTimerWidget({
    required this.elapsed,
    required this.isPaused,
    super.key,
  });

  final Duration elapsed;
  final bool isPaused;

  static String format(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      children: [
        Text(
          isPaused ? 'Turno pausado' : 'Tempo no turno',
          style: AppTypography.labelCaps(brightness),
        ),
        const SizedBox(height: 4),
        Text(
          format(elapsed),
          style: AppTypography.iosLargeTitle(brightness).copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
            fontWeight: FontWeight.w700,
            color: isPaused ? AppColors.warningAmber : null,
          ),
        ),
      ],
    );
  }
}
