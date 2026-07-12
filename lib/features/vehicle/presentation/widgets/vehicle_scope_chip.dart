import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../providers/vehicle_providers.dart';
import 'vehicle_picker_sheet.dart';

/// Chip de escopo de veículo — superfície elevada quieta.
class VehicleScopeChip extends ConsumerWidget {
  const VehicleScopeChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final scopedId = ref.watch(scopedVehicleIdProvider);
    final vehicles = ref.watch(vehiclesListProvider).valueOrNull ?? const [];
    final active = ref.watch(activeVehicleProvider).valueOrNull;

    final label = _resolveLabel(
      scopedId: scopedId,
      vehicles: vehicles,
      active: active,
    );

    return Semantics(
      button: true,
      label: 'Veículo: $label',
      child: GestureDetector(
        onTap: () {
          DfHaptics.light();
          showVehiclePickerSheet(context);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: AppRadius.xlAll,
            border: Border.fromBorderSide(AppElevation.hairline(brightness)),
            boxShadow: AppElevation.surfaceCard(brightness),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brandBlue.withValues(alpha: 0.10),
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_outlined,
                    size: 16,
                    color: AppColors.brandBlue,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: AppTypography.iosCaption(brightness).copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.expand_more_rounded,
                  size: 18,
                  color: AppColors.secondaryLabel(Theme.of(context)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _resolveLabel({
    required String? scopedId,
    required List<VehicleEntity> vehicles,
    required VehicleEntity? active,
  }) {
    if (scopedId == null) {
      if (vehicles.length <= 1 && active != null) {
        return active.displayName;
      }
      return 'Todos os veículos';
    }

    for (final vehicle in vehicles) {
      if (vehicle.id == scopedId) return vehicle.displayName;
    }
    return active?.displayName ?? 'Veículo';
  }
}
