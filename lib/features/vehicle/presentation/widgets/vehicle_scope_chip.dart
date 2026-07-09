import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../providers/vehicle_providers.dart';
import 'vehicle_picker_sheet.dart';

/// Chip premium de escopo de veículo — glass pill com haptic.
class VehicleScopeChip extends ConsumerWidget {
  const VehicleScopeChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
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
            color: AppColors.skyBlue.withValues(alpha: 0.12),
            borderRadius: AppRadius.lgAll,
            border: Border.all(
              color: AppColors.skyBlue.withValues(alpha: 0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.skyBlue.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.directions_car_filled_outlined,
                  size: 18,
                  color: AppColors.skyBlue,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.skyBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.expand_more_rounded,
                  size: 18,
                  color: AppColors.skyBlue.withValues(alpha: 0.7),
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
