import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../earnings/presentation/screens/earnings_screen.dart';
import '../../../expenses/presentation/screens/expenses_screen.dart';
import '../../../vehicle/domain/entities/vehicle_entity.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../../vehicle/presentation/screens/vehicle_form_screen.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/driveflow_tab_count.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../../shared/widgets/driveflow_main_shell.dart';

/// Shell principal pós-login com 5 abas e lazy mount.
class MainShellScreen extends HookConsumerWidget {
  const MainShellScreen({
    super.key,
    this.initialTab = DriveFlowTab.dashboard,
  });

  final int initialTab;

  static int resolveInitialTab(String? value) =>
      DriveFlowTab.fromQueryParam(value);

  static String _homeLocationForTab(int tab) {
    if (tab == DriveFlowTab.dashboard) return AppRoutes.home;
    return '${AppRoutes.home}?tab=${DriveFlowTab.queryParamFor(tab)}';
  }

  static int? _tabFromGoRouter(BuildContext context) {
    try {
      final tabParam = GoRouterState.of(context).uri.queryParameters['tab'];
      return DriveFlowTab.fromQueryParam(tabParam);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localTab = useState(initialTab);
    final routeTab = _tabFromGoRouter(context);
    final selectedIndex = routeTab ?? localTab.value;
    final activatedTabs = useState(<int>{initialTab});

    final tabBodies = useMemoized(
      () => const [
        DashboardScreen(),
        EarningsScreen(),
        ExpensesScreen(),
        ReportsScreen(),
        ProfileScreen(),
      ],
    );

    void onNavIndexChanged(int index) {
      activatedTabs.value = {...activatedTabs.value, index};
      if (routeTab != null) {
        context.go(_homeLocationForTab(index));
        return;
      }
      localTab.value = index;
    }

    useEffect(() {
      activatedTabs.value = {...activatedTabs.value, selectedIndex};
      return null;
    }, [selectedIndex]);

    return DriveFlowMainShell(
      selectedIndex: selectedIndex,
      onNavIndexChanged: onNavIndexChanged,
      tabBodies: tabBodies,
      activatedTabIndices: activatedTabs.value,
    );
  }
}

/// Tela full-screen para adicionar veículo.
class AddVehicleScreen extends ConsumerWidget {
  const AddVehicleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesListProvider).valueOrNull ?? const [];

    return VehicleFormScreen(
      title: 'Adicionar veículo',
      subtitle:
          'Cadastre outro carro para separar abastecimentos, manutenções e relatórios.',
      submitLabel: 'Salvar veículo',
      markAsDefault: vehicles.isEmpty,
      onSaved: () => context.pop(),
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

    return vehiclesAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Erro: $e')),
      ),
      data: (vehicles) {
        final vehicle = _resolveVehicle(vehicles, vehicleId);
        if (vehicle == null) {
          return Scaffold(
            body: Center(
              child: Text(
                'Nenhum veículo encontrado.',
                style: theme.textTheme.bodyLarge,
              ),
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
