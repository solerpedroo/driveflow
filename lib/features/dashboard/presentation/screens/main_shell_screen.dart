import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../../vehicle/presentation/screens/vehicle_form_screen.dart';
import '../../../../core/constants/driveflow_tab_count.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../../shared/widgets/driveflow_main_shell.dart';
import '../../../../shared/widgets/driveflow_tab_placeholder.dart';

/// Shell principal pós-login com 5 abas.
class MainShellScreen extends HookConsumerWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(DriveFlowTab.dashboard);

    final tabBodies = useMemoized(
      () => const [
        DashboardScreen(),
        DriveFlowTabPlaceholder(
          title: 'Ganhos',
          description:
              'Registre corridas por plataforma, valor e horas trabalhadas.',
          icon: Icons.payments_outlined,
          waveLabel: 'Onda 3 — Ganhos e despesas',
        ),
        DriveFlowTabPlaceholder(
          title: 'Despesas',
          description:
              'Controle pedágios, combustível, manutenção e outros custos.',
          icon: Icons.receipt_long_outlined,
          waveLabel: 'Onda 3 — Ganhos e despesas',
        ),
        DriveFlowTabPlaceholder(
          title: 'Relatórios',
          description:
              'Exporte PDF/CSV e acompanhe lucro, custo/km e metas.',
          icon: Icons.bar_chart_rounded,
          waveLabel: 'Onda 7 — Dashboard e relatórios',
        ),
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

/// Tela full-screen para editar veículo (push a partir do perfil).
class EditVehicleScreen extends ConsumerWidget {
  const EditVehicleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(activeVehicleProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar veículo'),
        backgroundColor: Colors.transparent,
      ),
      body: vehicleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (vehicle) {
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
}
