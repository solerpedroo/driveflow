import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../earnings/presentation/screens/earnings_screen.dart';
import '../../../expenses/presentation/screens/expenses_screen.dart';
import '../../../vehicle/domain/entities/vehicle_entity.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../../vehicle/presentation/screens/vehicle_form_screen.dart';
import '../../../../core/constants/driveflow_tab_count.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../../shared/widgets/driveflow_main_shell.dart';

/// Shell principal pós-login com 5 abas.
class MainShellScreen extends HookConsumerWidget {
  const MainShellScreen({
    super.key,
    this.initialTab = DriveFlowTab.dashboard,
  });

  final int initialTab;

  static int resolveInitialTab(String? value) {
    if (value == null || value.isEmpty) return DriveFlowTab.dashboard;

    final parsed = int.tryParse(value);
    if (parsed != null) return _normalizeTab(parsed);

    switch (value.toLowerCase()) {
      case 'dashboard':
        return DriveFlowTab.dashboard;
      case 'earnings':
        return DriveFlowTab.earnings;
      case 'expenses':
        return DriveFlowTab.expenses;
      case 'reports':
        return DriveFlowTab.reports;
      case 'profile':
        return DriveFlowTab.profile;
      default:
        return DriveFlowTab.dashboard;
    }
  }

  static int _normalizeTab(int tab) {
    if (tab < DriveFlowTab.dashboard || tab >= kDriveFlowMainTabCount) {
      return DriveFlowTab.dashboard;
    }
    return tab;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(_normalizeTab(initialTab));

    final tabBodies = useMemoized(
      () => const [
        DashboardScreen(),
        EarningsScreen(),
        ExpensesScreen(),
        ReportsScreen(),
        ProfileScreen(),
      ],
    );

    return DriveFlowMainShell(
      selectedIndex: selectedIndex.value,
      onNavIndexChanged: (index) => selectedIndex.value = index,
      tabBodies: tabBodies,
    );
  }
}

/// Tela full-screen para adicionar veículo.
class AddVehicleScreen extends ConsumerWidget {
  const AddVehicleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesListProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar veículo'),
        backgroundColor: Colors.transparent,
      ),
      body: VehicleFormScreen(
        title: 'Novo veículo',
        subtitle:
            'Cadastre outro carro para separar abastecimentos, manutenções e relatórios.',
        submitLabel: 'Salvar veículo',
        markAsDefault: vehicles.isEmpty,
        onSaved: () => context.pop(),
      ),
    );
  }
}

/// Tela full-screen para editar veículo (push a partir do perfil).
class EditVehicleScreen extends ConsumerWidget {
  const EditVehicleScreen({this.vehicleId, super.key});

  final String? vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar veículo'),
        backgroundColor: Colors.transparent,
      ),
      body: vehiclesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (vehicles) {
          final vehicle = _resolveVehicle(vehicles, vehicleId);
          if (vehicle == null) {
            return Center(
              child: Text(
                'Nenhum veículo encontrado.',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }
          return VehicleFormScreen(
            vehicle: vehicle,
            title: 'Editar veículo',
            subtitle: 'Atualize os dados do ${vehicle.displayName}.',
            submitLabel: 'Salvar alterações',
            onSaved: () => context.pop(),
          );
        },
      ),
    );
  }

  static VehicleEntity? _resolveVehicle(
    List<VehicleEntity> vehicles,
    String? vehicleId,
  ) {
    if (vehicleId != null) {
      for (final vehicle in vehicles) {
        if (vehicle.id == vehicleId) return vehicle;
      }
      return null;
    }
    if (vehicles.isEmpty) return null;
    return vehicles.firstWhere(
      (v) => v.isDefault,
      orElse: () => vehicles.first,
    );
  }
}
