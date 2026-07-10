import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/platform_trip_entity.dart';

/// Tile de corrida sincronizada no histórico.
class PlatformTripTile extends StatelessWidget {
  const PlatformTripTile({required this.trip, super.key});

  final PlatformTripEntity trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DfCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      trip.platform.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!trip.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warningAmber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          trip.status.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.warningAmber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateUtilsDriveFlow.dayMonthYear.format(trip.startedAt)} · '
                  '${_formatTime(trip.startedAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                  ),
                ),
                if (trip.pickupLabel != null || trip.dropoffLabel != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${trip.pickupLabel ?? '—'} → ${trip.dropoffLabel ?? '—'}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                if (trip.distanceKm != null || trip.durationMinutes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (trip.distanceKm != null)
                        '${trip.distanceKm!.toStringAsFixed(1)} km',
                      if (trip.durationMinutes != null) '${trip.durationMinutes} min',
                    ].join(' · '),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.secondaryLabel(theme),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(trip.driverPayout),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.profitGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (trip.tipAmount > 0)
                Text(
                  '+${CurrencyFormatter.format(trip.tipAmount)} gorjeta',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.skyBlue,
                  ),
                ),
              if (trip.platformFee > 0)
                Text(
                  'Taxa ${trip.takeRatePercent.toStringAsFixed(0)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime value) {
    final local = value.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
