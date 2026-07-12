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
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_hero_wealth_card.dart';
import '../../../../shared/widgets/design_system/df_grouped_section.dart';
import '../../../../shared/widgets/design_system/df_header_row.dart';
import '../../../../shared/widgets/design_system/df_section_header.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_tab_scroll_view.dart';
import '../../../../shared/widgets/design_system/df_text_field.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_value_stats_card.dart';

/// Perfil no padrão Mescla — avatar, métricas hero, conta agrupada e sessão.
class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hidden = ref.watch(valueVisibilityHiddenProvider);
    final user = ref.watch(userProfileProvider).valueOrNull ??
        ref.watch(authStateProvider).valueOrNull;
    final isTaxiDriver = ref.watch(isTaxiDriverProvider);
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

    return DfTabScrollView(
      onRefresh: () async {
        ref.invalidate(userProfileProvider);
        ref.invalidate(vehiclesListProvider);
        ref.invalidate(dashboardMonthProvider);
        ref.invalidate(earningsStreamProvider);
      },
      children: [
        const DfHeaderRow(),
        DfScreenTitleRow(
          title: 'Perfil',
          hidden: hidden,
          onToggleVisibility: () => ref
              .read(valueVisibilityHiddenProvider.notifier)
              .state = !hidden,
        ),
        _PerfilUserCard(
          user: user,
          isLoading: mutation.isLoading,
          editingName: editingName.value,
          nameController: nameController,
          onPickAvatar: pickAvatar,
          onSaveName: saveName,
          onEditName: () => editingName.value = true,
          onCancelEdit: () => editingName.value = false,
          mutationError: mutation.hasError ? mutation.error.toString() : null,
        ),
        monthAsync.when(
          loading: () => const SizedBox(
            height: 140,
            child: DfSkeleton(itemCount: 1),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (month) {
            final rides = earningsAsync.valueOrNull?.length ?? 0;
            return ProfileValueStatsCard(
              month: month,
              totalRides: rides,
              hideValue: hidden,
            );
          },
        ),
        vehiclesAsync.when(
          loading: () => const DfSkeleton(itemCount: 2),
          error: (_, __) => const DfEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Não foi possível carregar veículos',
            subtitle: 'Puxe para baixo para tentar novamente.',
          ),
          data: (vehicles) => _VehiclesSection(
            vehicles: vehicles,
            isBusy: vehicleMutation.isLoading,
            onAdd: () => context.push(AppRoutes.addVehicle),
            onEdit: (id) => context.push('${AppRoutes.editVehicle}?id=$id'),
          ),
        ),
        DfGroupedSection(
          header: 'Conta',
          children: [
            if (!isTaxiDriver)
              DfGroupedRow(
                title: 'Apps conectados',
                subtitle: 'Uber, 99 e InDrive',
                leading: Icon(Icons.hub_outlined, color: AppColors.brandBlue),
                showChevron: true,
                onTap: () => context.push(AppRoutes.platformIntegrations),
              ),
            DfGroupedRow(
              title: 'Abastecimentos',
              subtitle: 'Histórico e custo por km',
              leading: Icon(
                Icons.local_gas_station_outlined,
                color: AppColors.brandBlue,
              ),
              showChevron: true,
              onTap: () => context.push(AppRoutes.fuelHistory),
            ),
            DfGroupedRow(
              title: 'Manutenções',
              subtitle: 'Lembretes e histórico',
              leading: Icon(
                Icons.build_circle_outlined,
                color: AppColors.brandBlue,
              ),
              showChevron: true,
              onTap: () => context.push(AppRoutes.maintenanceHistory),
            ),
            DfGroupedRow(
              title: 'Importar extrato',
              subtitle: 'Extrato do banco ou arquivo do app',
              leading: Icon(
                Icons.upload_file_outlined,
                color: AppColors.brandBlue,
              ),
              showChevron: true,
              onTap: () => context.push(AppRoutes.importStatement),
            ),
            DfGroupedRow(
              title: 'Análises',
              subtitle: 'Tendências e comparação',
              leading: Icon(
                Icons.bar_chart_outlined,
                color: AppColors.brandBlue,
              ),
              showChevron: true,
              onTap: () => context.push(AppRoutes.analytics),
            ),
            DfGroupedRow(
              title: 'Insights',
              subtitle: 'Melhor horário e projeções',
              leading: Icon(
                Icons.auto_awesome_outlined,
                color: AppColors.brandBlue,
              ),
              showChevron: true,
              onTap: () => context.push(AppRoutes.insights),
            ),
            DfGroupedRow(
              title: 'Metas',
              subtitle: 'Lucro-alvo diário e mensal',
              leading: Icon(Icons.flag_outlined, color: AppColors.brandBlue),
              showChevron: true,
              onTap: () => context.push(AppRoutes.goals),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DfSectionHeader(
              title: 'DriveFlow IA',
              eyebrow: 'Assistente',
            ),
            const SizedBox(height: AppSpacing.md),
            DfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pergunte sobre lucro, metas e manutenção com seus dados reais.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryLabel(theme),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DfButton(
                    label: 'Abrir assistente',
                    icon: Icons.chat_bubble_outline_rounded,
                    variant: DfButtonVariant.tonal,
                    onPressed: () => context.push(AppRoutes.aiChat),
                    expand: false,
                  ),
                ],
              ),
            ),
          ],
        ),
        DfGroupedSection(
          header: 'Sessão',
          children: [
            _DestructiveGroupedRow(
              title: 'Sair da conta',
              icon: Icons.logout_rounded,
              onTap: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
            ),
          ],
        ),
      ],
    );
  }
}

class _PerfilUserCard extends StatelessWidget {
  const _PerfilUserCard({
    required this.user,
    required this.isLoading,
    required this.editingName,
    required this.nameController,
    required this.onPickAvatar,
    required this.onSaveName,
    required this.onEditName,
    required this.onCancelEdit,
    this.mutationError,
  });

  final UserEntity? user;
  final bool isLoading;
  final bool editingName;
  final TextEditingController nameController;
  final VoidCallback onPickAvatar;
  final VoidCallback onSaveName;
  final VoidCallback onEditName;
  final VoidCallback onCancelEdit;
  final String? mutationError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final photoUrl = user?.photoUrl;
    final initials = user?.displayName.isNotEmpty == true
        ? user!.displayName.characters.first.toUpperCase()
        : '?';

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.brandBlue.withValues(alpha: 0.12),
                backgroundImage: photoUrl != null
                    ? CachedNetworkImageProvider(photoUrl)
                    : null,
                child: photoUrl == null
                    ? Text(
                        initials,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.brandBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : null,
              ),
              if (isLoading)
                SizedBox(
                  width: 72,
                  height: 72,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.brandBlue.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.brandBlue,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.brandBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                user?.roleBadgeLabel ?? 'Motorista',
                style: AppTypography.labelCaps(brightness).copyWith(
                  color: AppColors.brandBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (editingName) ...[
            DfTextField(
              controller: nameController,
              label: 'Nome',
              validator: (v) =>
                  Validators.requiredField(v, fieldName: 'Nome'),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: DfButton(
                    label: 'Salvar',
                    isLoading: isLoading,
                    onPressed: onSaveName,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                DfButton(
                  label: 'Cancelar',
                  variant: DfButtonVariant.outlined,
                  onPressed: onCancelEdit,
                  expand: false,
                ),
              ],
            ),
          ] else ...[
            Text(
              user?.displayName ?? 'Motorista',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (user?.email != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                user!.email!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryLabel(theme),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DfButton(
                  label: 'Editar nome',
                  icon: Icons.edit_outlined,
                  variant: DfButtonVariant.outlined,
                  onPressed: onEditName,
                  expand: false,
                ),
                const SizedBox(width: AppSpacing.sm),
                DfButton(
                  label: 'Alterar foto',
                  icon: Icons.photo_camera_outlined,
                  variant: DfButtonVariant.tonal,
                  onPressed: isLoading ? null : onPickAvatar,
                  expand: false,
                ),
              ],
            ),
          ],
          if (mutationError != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              mutationError!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VehiclesSection extends StatelessWidget {
  const _VehiclesSection({
    required this.vehicles,
    required this.isBusy,
    required this.onAdd,
    required this.onEdit,
  });

  final List<VehicleEntity> vehicles;
  final bool isBusy;
  final VoidCallback onAdd;
  final ValueChanged<String> onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DfSectionHeader(
          title: 'Meus veículos',
          eyebrow: 'Garagem',
          action: isBusy ? null : onAdd,
          actionLabel: 'Adicionar',
        ),
        const SizedBox(height: AppSpacing.md),
        if (vehicles.isEmpty)
          DfCard(
            child: const DfEmptyState(
              variant: DfEmptyStateVariant.illustrated,
              icon: Icons.directions_car_outlined,
              title: 'Nenhum veículo cadastrado',
              subtitle: 'Adicione seu carro para calcular custos e metas.',
            ),
          )
        else
          DfGroupedSection(
            children: [
              for (final vehicle in vehicles)
                DfGroupedRow(
                  title: vehicle.displayName,
                  subtitle:
                      '${vehicle.year} · ${vehicle.fuelLabel}'
                      '${vehicle.plate != null ? ' · ${vehicle.plate}' : ''}',
                  leading: Icon(
                    Icons.directions_car_outlined,
                    color: AppColors.brandBlue,
                  ),
                  trailing: vehicle.isDefault
                      ? Text(
                          'Padrão',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.brandBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                  showChevron: true,
                  onTap: isBusy ? null : () => onEdit(vehicle.id),
                ),
            ],
          ),
      ],
    );
  }
}

class _DestructiveGroupedRow extends StatelessWidget {
  const _DestructiveGroupedRow({
    required this.title,
    required this.onTap,
    this.icon,
  });

  final String title;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: AppColors.expenseCoral),
                const SizedBox(width: AppSpacing.md),
              ],
              Text(
                title,
                style: AppTypography.iosBody(brightness).copyWith(
                  color: AppColors.expenseCoral,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
