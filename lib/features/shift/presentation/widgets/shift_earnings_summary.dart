import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/shift_session_summary.dart';

/// KPIs ao vivo do turno — ganhos, corridas e R$/h.
class ShiftEarningsSummary extends StatelessWidget {
  const ShiftEarningsSummary({
    required this.summary,
    required this.hideValue,
    super.key,
  });

  final ShiftSessionSummary summary;
  final bool hideValue;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Row(
      children: [
        Expanded(
          child: _Stat(
            label: 'Ganhos',
            value: hideValue
                ? '•••'
                : CurrencyFormatter.format(summary.revenue),
            brightness: brightness,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _Stat(
            label: 'Corridas',
            value: hideValue ? '•••' : '${summary.rides}',
            brightness: brightness,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _Stat(
            label: 'R\$/h',
            value: hideValue
                ? '•••'
                : summary.revenuePerHour == null
                    ? '—'
                    : CurrencyFormatter.format(summary.revenuePerHour!),
            brightness: brightness,
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.brightness,
  });

  final String label;
  final String value;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.iosFootnote(brightness)),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.iosHeadline(brightness).copyWith(
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
