import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../providers/vehicle_providers.dart';
import 'vehicle_picker_sheet.dart';

/// Chip de escopo de veículo — exibe seleção atual e abre o seletor.
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

    return ActionChip(
      avatar: const Icon(Icons.directions_car_filled_outlined, size: 18),
      label: Text(label),
      labelStyle: theme.textTheme.labelLarge,
      backgroundColor: AppColors.electricTeal.withValues(alpha: 0.12),
      side: BorderSide(color: AppColors.electricTeal.withValues(alpha: 0.35)),
      onPressed: () => showVehiclePickerSheet(context),
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
