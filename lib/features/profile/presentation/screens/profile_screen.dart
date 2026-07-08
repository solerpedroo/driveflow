import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../authentication/domain/entities/user_entity.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../authentication/presentation/widgets/auth_primary_button.dart';
import '../../../authentication/presentation/widgets/auth_text_field.dart';
import '../../../vehicle/domain/entities/vehicle_entity.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/driveflow_glass_card.dart';
import '../providers/profile_providers.dart';

/// Aba Perfil — dados do motorista e atalhos.
class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(userProfileProvider).valueOrNull ??
        ref.watch(authStateProvider).valueOrNull;
    final vehiclesAsync = ref.watch(vehiclesListProvider);
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

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: SliverToBoxAdapter(
            child: Text('Perfil', style: theme.textTheme.headlineSmall),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          sliver: SliverToBoxAdapter(
            child: DriveFlowGlassCard(
              child: Column(
                children: [
                  _AvatarSection(
                    user: user,
                    isLoading: mutation.isLoading,
                    onPick: pickAvatar,
                  ),
                  const SizedBox(height: 16),
                  if (editingName.value) ...[
                    AuthTextField(
                      controller: nameController,
                      label: 'Nome',
                      validator: (v) =>
                          Validators.requiredField(v, fieldName: 'Nome'),
                    ),
                    const SizedBox(height: 12),
                    AuthPrimaryButton(
                      label: 'Salvar nome',
                      isLoading: mutation.isLoading,
                      onPressed: saveName,
                    ),
                  ] else ...[
                    Text(user?.displayName ?? 'Motorista',
                        style: theme.textTheme.titleLarge),
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
                    OutlinedButton.icon(
                      onPressed: () => editingName.value = true,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar nome'),
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
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Text('Veículos', style: theme.textTheme.titleMedium),
                ),
                TextButton.icon(
                  onPressed: vehicleMutation.isLoading
                      ? null
                      : () => context.push(AppRoutes.addVehicle),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Adicionar'),
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
            error: (e, _) => SliverToBoxAdapter(child: Text('Erro: $e')),
            data: (vehicles) {
              if (vehicles.isEmpty) {
                return SliverToBoxAdapter(
                  child: DriveFlowGlassCard(
                    child: Text(
                      'Nenhum veículo cadastrado.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                );
              }

              return SliverList.separated(
                itemCount: vehicles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == vehicles.length - 1 ? 0 : 0,
                    ),
                    child: _VehicleCard(
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
                    ),
                  );
                },
              );
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: SliverToBoxAdapter(
            child: Text('Atalhos', style: theme.textTheme.titleMedium),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          sliver: SliverToBoxAdapter(
            child: DriveFlowGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => context.push(AppRoutes.fuelHistory),
                    icon: const Icon(Icons.local_gas_station_outlined),
                    label: const Text('Abastecimentos'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        context.push(AppRoutes.maintenanceHistory),
                    icon: const Icon(Icons.build_circle_outlined),
                    label: const Text('Manutenções'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: () => context.push(AppRoutes.analytics),
                    icon: const Icon(Icons.bar_chart_outlined),
                    label: const Text('Análises'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: () => context.push(AppRoutes.insights),
                    icon: const Icon(Icons.auto_awesome_outlined),
                    label: const Text('Insights'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: () => context.push(AppRoutes.goals),
                    icon: const Icon(Icons.flag_outlined),
                    label: const Text('Metas'),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: SliverToBoxAdapter(
            child: Text('Assistente', style: theme.textTheme.titleMedium),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          sliver: SliverToBoxAdapter(
            child: DriveFlowGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DriveFlow IA',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pergunte sobre lucro, metas, combustível e manutenção com seus dados reais.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryLabel(theme),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: () => context.push(AppRoutes.aiChat),
                    icon: const Icon(Icons.auto_awesome_outlined),
                    label: const Text('Abrir assistente'),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          sliver: SliverToBoxAdapter(
            child: TextButton.icon(
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sair da conta'),
            ),
          ),
        ),
      ],
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

    if (confirmed == true) {
      await ref.read(vehicleControllerProvider.notifier).delete(vehicle.id);
    }
  }
}

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

    return DriveFlowGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(vehicle.displayName,
                    style: theme.textTheme.titleMedium),
              ),
              if (vehicle.isDefault)
                Chip(
                  label: const Text('Padrão'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor:
                      AppColors.electricTeal.withValues(alpha: 0.15),
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: isBusy ? null : onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
              if (onSetDefault != null)
                OutlinedButton(
                  onPressed: isBusy ? null : onSetDefault,
                  child: const Text('Tornar padrão'),
                ),
              if (onDelete != null)
                TextButton(
                  onPressed: isBusy ? null : onDelete,
                  child: Text(
                    'Excluir',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

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

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.electricTeal.withValues(alpha: 0.15),
              backgroundImage:
                  photoUrl != null ? CachedNetworkImageProvider(photoUrl) : null,
              child: photoUrl == null
                  ? Text(
                      user?.displayName.characters.first.toUpperCase() ?? '?',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.electricTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            if (isLoading)
              const Positioned.fill(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: isLoading ? null : onPick,
          icon: const Icon(Icons.photo_camera_outlined),
          label: const Text('Alterar foto'),
        ),
      ],
    );
  }
}
