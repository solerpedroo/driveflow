import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../fuel/domain/entities/fuel_log_entity.dart';
import '../../../vehicle/domain/entities/vehicle_entity.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Card do último abastecimento.
class DashboardFuelCard extends StatelessWidget {
  const DashboardFuelCard({
    required this.vehicle,
    required this.lastFuel,
    super.key,
  });

  final VehicleEntity? vehicle;
  final FuelLogEntity? lastFuel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return DfCard(
      variant: DfCardVariant.elevated,
      onTap: vehicle != null
          ? () => context.push(AppRoutes.fuelHistory)
          : null,
      semanticLabel: 'Último abastecimento',
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandBlue.withValues(alpha: 0.10),
            ),
            child: const Icon(
              Icons.local_gas_station_rounded,
              color: AppColors.brandBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Último abastecimento',
                  style: AppTypography.labelCaps(brightness),
                ),
                const SizedBox(height: 4),
                if (lastFuel == null)
                  Text(
                    vehicle == null
                        ? 'Cadastre um veículo para registrar combustível.'
                        : 'Nenhum abastecimento ainda. Toque para registrar.',
                    style: AppTypography.iosBody(brightness).copyWith(
                      fontSize: 15,
                      color: AppColors.secondaryLabel(theme),
                      height: 1.35,
                    ),
                  )
                else ...[
                  Text(
                    lastFuel!.station?.isNotEmpty == true
                        ? lastFuel!.station!
                        : lastFuel!.fuelType.label,
                    style: AppTypography.iosHeadline(brightness).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${CurrencyFormatter.format(lastFuel!.totalAmount)} · '
                    '${lastFuel!.liters.toStringAsFixed(1)} L · '
                    '${lastFuel!.odometerKm.toStringAsFixed(0)} km',
                    style: AppTypography.iosFootnote(brightness),
                  ),
                  if (lastFuel!.hasMetrics) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${lastFuel!.kmPerLiter!.toStringAsFixed(1)} km/L · '
                      '${CurrencyFormatter.format(lastFuel!.costPerKm!)}/km',
                      style: AppTypography.iosCaption(brightness).copyWith(
                        color: AppColors.brandBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          if (vehicle != null)
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondaryLabel(theme).withValues(alpha: 0.45),
            ),
        ],
      ),
    );
  }
}
