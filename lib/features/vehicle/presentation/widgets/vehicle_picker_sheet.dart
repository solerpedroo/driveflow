import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../providers/vehicle_providers.dart';

Future<void> showVehiclePickerSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => const VehiclePickerSheet(),
  );
}

/// Bottom sheet para trocar o veículo ativo ou ver todos.
class VehiclePickerSheet extends ConsumerWidget {
  const VehiclePickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vehiclesAsync = ref.watch(vehiclesListProvider);
    final scopedId = ref.watch(scopedVehicleIdProvider);
    final mutation = ref.watch(vehicleControllerProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: vehiclesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Erro ao carregar veículos: $e'),
          data: (vehicles) {
            if (vehicles.isEmpty) {
              return Text(
                'Nenhum veículo cadastrado.',
                style: theme.textTheme.bodyLarge,
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Selecionar veículo', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Filtra ganhos e despesas. Combustível e manutenção seguem o veículo selecionado.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                  ),
                ),
                const SizedBox(height: 16),
                if (vehicles.length > 1)
                  _ScopeTile(
                    title: 'Todos os veículos',
                    subtitle: 'Ganhos e despesas consolidados',
                    selected: scopedId == null,
                    onTap: mutation.isLoading
                        ? null
                        : () async {
                            await ref
                                .read(vehicleControllerProvider.notifier)
                                .selectScope(vehicleId: null);
                            if (context.mounted) Navigator.pop(context);
                          },
                  ),
                ...vehicles.map(
                  (vehicle) => _ScopeTile(
                    title: vehicle.displayName,
                    subtitle: _vehicleSubtitle(vehicle),
                    selected: scopedId == vehicle.id,
                    onTap: mutation.isLoading
                        ? null
                        : () async {
                            await ref
                                .read(vehicleControllerProvider.notifier)
                                .selectScope(vehicleId: vehicle.id);
                            if (context.mounted) Navigator.pop(context);
                          },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _vehicleSubtitle(VehicleEntity vehicle) {
    final parts = <String>[
      '${vehicle.year}',
      vehicle.fuelLabel,
      if (vehicle.plate != null) vehicle.plate!,
      if (vehicle.isDefault) 'Padrão',
    ];
    return parts.join(' · ');
  }
}

class _ScopeTile extends StatelessWidget {
  const _ScopeTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? AppColors.electricTeal : null,
      ),
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.secondaryLabel(theme),
        ),
      ),
      onTap: onTap,
    );
  }
}
