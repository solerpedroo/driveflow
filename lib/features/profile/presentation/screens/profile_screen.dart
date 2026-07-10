import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../authentication/domain/entities/user_entity.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../vehicle/domain/entities/vehicle_entity.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_settings_row.dart';
import '../../../../shared/widgets/design_system/df_text_field.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_plan_card.dart';
import '../widgets/profile_value_stats_card.dart';

/// Aba Perfil — dados do motorista, veículos e atalhos.
class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(userProfileProvider).valueOrNull ??
        ref.watch(authStateProvider).valueOrNull;
    final vehiclesAsync = ref.watch(vehiclesListProvider);
    final monthAsync = ref.watch(dashboardMonthProvider);
    final earningsAsync = ref.watch(earningsStreamProvider);
    final mutation = ref.watch(profileControllerProvider);
    final vehicleMutation = ref.watch(vehicleControllerProvider);
    final nameController = useTextEditingController(text: user?.name ?? '');
    final editingName = useState(false);

    useEffect(() {
      nameController.text = user?.name ?? '';
      return null;
    }, [user?.name]);

    Future<void> pickAvatar() async {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return;
      await ref
          .read(profileControllerProvider.notifier)
          .uploadAvatar(File(picked.path));
    }

    Future<void> saveName() async {
      if (Validators.requiredField(nameController.text, fieldName: 'Nome') !=
          null) {
        return;
      }
      final updated = await ref
          .read(profileControllerProvider.notifier)
          .updateName(nameController.text);
      if (updated != null) {
        editingName.value = false;
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: SliverToBoxAdapter(
            child: Text('Perfil', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          ),
        ),

        // ── Avatar + Nome ────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          sliver: SliverToBoxAdapter(
            child: DfCard(
              child: Column(
                children: [
                  _AvatarSection(
                    user: user,
                    isLoading: mutation.isLoading,
                    onPick: pickAvatar,
                  ),
                  const SizedBox(height: 16),
                  if (editingName.value) ...[
                    DfTextField(
                      controller: nameController,
                      label: 'Nome',
                      validator: (v) =>
                          Validators.requiredField(v, fieldName: 'Nome'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DfButton(
                            label: 'Salvar',
                            isLoading: mutation.isLoading,
                            onPressed: saveName,
                          ),
                        ),
                        const SizedBox(width: 8),
                        DfButton(
                          label: 'Cancelar',
                          variant: DfButtonVariant.outlined,
                          onPressed: () => editingName.value = false,
                          expand: false,
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      user?.displayName ?? 'Motorista',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (user?.email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        user!.email!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryLabel(theme),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    DfButton(
                      label: 'Editar nome',
                      icon: Icons.edit_outlined,
                      variant: DfButtonVariant.outlined,
                      onPressed: () => editingName.value = true,
                      expand: false,
                    ),
                  ],
                  if (mutation.hasError) ...[
                    const SizedBox(height: 12),
                    Text(
                      mutation.error.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // ── Estatísticas do mês ──────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: SliverToBoxAdapter(
            child: monthAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (month) {
                final rides = earningsAsync.valueOrNull?.length ?? 0;
                return ProfileValueStatsCard(
                  month: month,
                  totalRides: rides,
                );
              },
            ),
          ),
        ),

        // ── Plano Pro ────────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: const SliverToBoxAdapter(child: ProfilePlanCard()),
        ),

        // ── Veículos ─────────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Meus veículos',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                DfButton(
                  label: 'Adicionar',
                  icon: Icons.add_circle_outline,
                  variant: DfButtonVariant.tonal,
                  onPressed: vehicleMutation.isLoading
                      ? null
                      : () => context.push(AppRoutes.addVehicle),
                  expand: false,
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          sliver: vehiclesAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Text('Erro ao carregar veículos: $e'),
            ),
            data: (vehicles) {
              if (vehicles.isEmpty) {
                return SliverToBoxAdapter(
                  child: DfCard(
                    child: const DfEmptyState(
                      variant: DfEmptyStateVariant.illustrated,
                      icon: Icons.directions_car_outlined,
                      title: 'Nenhum veículo cadastrado',
                      subtitle: 'Adicione seu carro para calcular custos e metas.',
                    ),
                  ),
                );
              }

              return SliverList.separated(
                itemCount: vehicles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return _VehicleCard(
                    vehicle: vehicle,
                    isBusy: vehicleMutation.isLoading,
                    onEdit: () => context.push(
                      '${AppRoutes.editVehicle}?id=${vehicle.id}',
                    ),
                    onSetDefault: vehicle.isDefault
                        ? null
                        : () => ref
                            .read(vehicleControllerProvider.notifier)
                            .setDefault(vehicle.id),
                    onDelete: vehicles.length <= 1
                        ? null
                        : () => _confirmDelete(context, ref, vehicle),
                  );
                },
              );
            },
          ),
        ),

        // ── Integrações de apps ────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Integrações',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          sliver: SliverToBoxAdapter(
            child: DfCard(
              child: DfSettingsRow(
                icon: Icons.hub_outlined,
                label: 'Apps conectados',
                subtitle: 'Uber, 99 e InDrive — sync automático de ganhos',
                accentColor: AppColors.profitGreen,
                onTap: () => context.push(AppRoutes.platformIntegrations),
              ),
            ),
          ),
        ),

        // ── Atalhos ──────────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Atalhos',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          sliver: SliverToBoxAdapter(
            child: DfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DfSettingsRow(
                    icon: Icons.local_gas_station_outlined,
                    label: 'Abastecimentos',
                    subtitle: 'Histórico e custo por km',
                    onTap: () => context.push(AppRoutes.fuelHistory),
                  ),
                  DfSettingsRow(
                    icon: Icons.build_circle_outlined,
                    label: 'Manutenções',
                    subtitle: 'Lembretes e histórico do veículo',
                    onTap: () => context.push(AppRoutes.maintenanceHistory),
                  ),
                  DfSettingsRow(
                    icon: Icons.upload_file_outlined,
                    label: 'Importar extrato',
                    subtitle: 'Nubank, Inter ou OFX em segundos',
                    onTap: () => context.push(AppRoutes.importStatement),
                  ),
                  DfSettingsRow(
                    icon: Icons.bar_chart_outlined,
                    label: 'Análises',
                    subtitle: 'Tendências e comparação de períodos',
                    onTap: () => context.push(AppRoutes.analytics),
                  ),
                  DfSettingsRow(
                    icon: Icons.auto_awesome_outlined,
                    label: 'Insights',
                    subtitle: 'Melhor horário e projeções',
                    accentColor: AppColors.profitGreen,
                    onTap: () => context.push(AppRoutes.insights),
                  ),
                  DfSettingsRow(
                    icon: Icons.flag_outlined,
                    label: 'Metas',
                    subtitle: 'Acompanhe seu lucro-alvo',
                    accentColor: AppColors.skyBlueDim,
                    showDivider: false,
                    onTap: () => context.push(AppRoutes.goals),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Assistente IA ────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Assistente',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          sliver: SliverToBoxAdapter(
            child: DfCard(
              variant: DfCardVariant.hero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.skyBlue, AppColors.skyBlueDim],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DriveFlow IA',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Copiloto financeiro',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.secondaryLabel(theme),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pergunte sobre lucro, metas, combustível e manutenção com seus dados reais.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryLabel(theme),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DfSettingsRow(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Abrir assistente',
                    subtitle: 'Respostas com seus números',
                    accentColor: AppColors.skyBlueDim,
                    showDivider: false,
                    onTap: () => context.push(AppRoutes.aiChat),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Sair ─────────────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, AppSpacing.xl, 24, 48),
          sliver: SliverToBoxAdapter(
            child: DfButton(
              label: 'Sair da conta',
              icon: Icons.logout_rounded,
              variant: DfButtonVariant.outlined,
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
            ),
          ),
        ),
      ],
    ),
  );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    VehicleEntity vehicle,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir veículo'),
        content: Text(
          'Remover ${vehicle.displayName}? Abastecimentos e manutenções vinculados também serão apagados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(vehicleControllerProvider.notifier).delete(vehicle.id);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card de veículo
// ─────────────────────────────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.isBusy,
    required this.onEdit,
    this.onSetDefault,
    this.onDelete,
  });

  final VehicleEntity vehicle;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback? onSetDefault;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  vehicle.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (vehicle.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.skyBlue.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Padrão',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.skyBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${vehicle.year} · ${vehicle.fuelLabel}'
            '${vehicle.plate != null ? ' · ${vehicle.plate}' : ''}'
            ' · ${vehicle.odometerKm.toStringAsFixed(0)} km',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryLabel(theme),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DfButton(
                label: 'Editar',
                icon: Icons.edit_outlined,
                variant: DfButtonVariant.tonal,
                onPressed: isBusy ? null : onEdit,
                expand: false,
              ),
              if (onSetDefault != null)
                DfButton(
                  label: 'Tornar padrão',
                  variant: DfButtonVariant.outlined,
                  onPressed: isBusy ? null : onSetDefault,
                  expand: false,
                ),
              if (onDelete != null)
                DfButton(
                  label: 'Excluir',
                  variant: DfButtonVariant.outlined,
                  onPressed: isBusy ? null : onDelete,
                  expand: false,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Seção de avatar
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({
    required this.user,
    required this.isLoading,
    required this.onPick,
  });

  final UserEntity? user;
  final bool isLoading;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoUrl = user?.photoUrl;
    final initials = user?.displayName.isNotEmpty == true
        ? user!.displayName.characters.first.toUpperCase()
        : '?';

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.skyBlue, AppColors.skyBlueSoft],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.skyBlue.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.skyBlue.withValues(alpha: 0.12),
                backgroundImage: photoUrl != null
                    ? CachedNetworkImageProvider(photoUrl)
                    : null,
                child: photoUrl == null
                    ? Text(
                        initials,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppColors.skyBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : null,
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 98,
                height: 98,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.skyBlue,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        DfButton(
          label: 'Alterar foto',
          icon: Icons.photo_camera_outlined,
          variant: DfButtonVariant.outlined,
          onPressed: isLoading ? null : onPick,
          expand: false,
        ),
      ],
    );
  }
}
