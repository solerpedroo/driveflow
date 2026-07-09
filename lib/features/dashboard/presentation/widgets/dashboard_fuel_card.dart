import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../fuel/domain/entities/fuel_log_entity.dart';
import '../../../vehicle/domain/entities/vehicle_entity.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
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

    return DfCard(
      onTap: vehicle != null
          ? () => context.push(AppRoutes.fuelHistory)
          : null,
      semanticLabel: 'Último abastecimento',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_gas_station_rounded,
                  color: AppColors.infoBlue),
              const SizedBox(width: AppSpacing.sm),
              Text('Último abastecimento', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (lastFuel == null)
            Text(
              vehicle == null
                  ? 'Cadastre um veículo para registrar combustível.'
                  : 'Nenhum abastecimento ainda. Toque para registrar.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryLabel(theme),
              ),
            )
          else ...[
            Text(
              lastFuel!.station?.isNotEmpty == true
                  ? lastFuel!.station!
                  : lastFuel!.fuelType.label,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${CurrencyFormatter.format(lastFuel!.totalAmount)} · '
              '${lastFuel!.liters.toStringAsFixed(1)} L · '
              '${lastFuel!.odometerKm.toStringAsFixed(0)} km',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryLabel(theme),
              ),
            ),
            if (lastFuel!.hasMetrics) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${lastFuel!.kmPerLiter!.toStringAsFixed(1)} km/L · '
                '${CurrencyFormatter.format(lastFuel!.costPerKm!)}/km',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.electricTeal,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
