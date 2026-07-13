import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/shift_history_entry.dart';
import 'shift_adherence_badge.dart';
import 'shift_timer_widget.dart';

/// Linha do histórico de turnos.
class ShiftHistoryTile extends StatelessWidget {
  const ShiftHistoryTile({
    required this.entry,
    required this.onTap,
    super.key,
  });

  final ShiftHistoryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateUtilsDriveFlow.dayMonthYear.format(entry.startedAt),
                      style: AppTypography.iosHeadline(brightness).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ShiftTimerWidget.format(entry.elapsed)} · '
                      '${entry.rides} corridas',
                      style: AppTypography.iosFootnote(brightness).copyWith(
                        color: AppColors.secondaryLabel(theme),
                      ),
                    ),
                  ],
                ),
              ),
              if (entry.totalPlanBlocks > 0)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ShiftAdherenceBadge(score: entry.adherenceScore),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(entry.revenue),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (entry.revenuePerHour != null)
                    Text(
                      '${CurrencyFormatter.format(entry.revenuePerHour!)}/h',
                      style: AppTypography.iosFootnote(brightness).copyWith(
                        color: AppColors.brandBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.secondaryLabel(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
