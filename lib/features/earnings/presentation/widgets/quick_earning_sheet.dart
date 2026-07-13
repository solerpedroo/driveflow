import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/errors/failure_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../../shared/widgets/design_system/df_filter_pill.dart';
import '../../../../shared/widgets/platform_brand_icon.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../data/datasources/quick_earning_storage.dart';
import '../../domain/entities/earning_entity.dart';
import '../../domain/entities/quick_earning_entry.dart';
import '../providers/earnings_providers.dart';
import '../providers/quick_earning_providers.dart';

const _defaultAmounts = [25.0, 35.0, 50.0, 75.0, 100.0];

/// Sheet de captura zero-fricção — plataforma + valor em dois toques.
class QuickEarningSheet extends HookConsumerWidget {
  const QuickEarningSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickEarningSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final driverType = ref.watch(driverTypeProvider);
    final platforms = ridePlatformsFor(driverType);
    final history = ref.watch(quickEarningHistoryProvider);
    final mutation = ref.watch(earningsControllerProvider);

    final selectedPlatform = useState<RidePlatform?>(null);
    final isSaving = useState(false);

    final amountOptions = history.isNotEmpty
        ? history.map((entry) => entry.amount).toSet().toList()
        : _defaultAmounts;

    Future<void> register({
      required RidePlatform platform,
      required double amount,
    }) async {
      if (isSaving.value || mutation.isLoading) return;
      isSaving.value = true;
      DfHaptics.light();

      final vehicleId = ref.read(scopedVehicleIdProvider) ??
          ref.read(activeVehicleProvider).valueOrNull?.id;
      final draft = EarningDraft(
        platform: platform,
        amount: amount,
        rides: 1,
        workedHours: 0,
        date: DateTime.now(),
        vehicleId: vehicleId,
        note: 'Ganho rápido',
      );

      final saved =
          await ref.read(earningsControllerProvider.notifier).save(draft: draft);
      if (!context.mounted) return;

      isSaving.value = false;
      if (saved != null) {
        await QuickEarningStorage.remember(platform: platform, amount: amount);
        ref.read(quickEarningHistoryVersionProvider.notifier).state++;
        if (context.mounted) Navigator.pop(context, true);
        return;
      }
      DfHaptics.medium();
    }

    void onPlatformTap(RidePlatform platform) {
      selectedPlatform.value = platform;
      DfHaptics.selection();
    }

    void onAmountTap(double amount) {
      final platform = selectedPlatform.value;
      if (platform == null) return;
      register(platform: platform, amount: amount);
    }

    void onHistoryTap(QuickEarningEntry entry) {
      register(platform: entry.platform, amount: entry.amount);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ganho rápido',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Dois toques: escolha o app e o valor.',
            style: AppTypography.iosFootnote(theme.brightness).copyWith(
              color: AppColors.secondaryLabel(theme),
            ),
          ),
          if (history.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Repetir último',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: history.take(4).map((entry) {
                return ActionChip(
                  avatar: PlatformBrandIcon.hasBrandAsset(entry.platform)
                      ? PlatformBrandIcon(
                          platform: entry.platform,
                          size: 18,
                          borderRadius: 4,
                        )
                      : null,
                  label: Text(
                    '${entry.platform.label} · ${CurrencyFormatter.format(entry.amount)}',
                  ),
                  onPressed: mutation.isLoading || isSaving.value
                      ? null
                      : () => onHistoryTap(entry),
                );
              }).toList(growable: false),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text(
            ref.watch(isTaxiDriverProvider) ? 'Canal' : 'App',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: platforms.map((platform) {
              return DfFilterPill(
                label: platform.label,
                selected: selectedPlatform.value == platform,
                leading: PlatformBrandIcon.hasBrandAsset(platform)
                    ? PlatformBrandIcon(
                        platform: platform,
                        size: 20,
                        borderRadius: 6,
                      )
                    : null,
                onSelected: () => onPlatformTap(platform),
              );
            }).toList(growable: false),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Valor',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: amountOptions.map((amount) {
              final enabled =
                  selectedPlatform.value != null && !mutation.isLoading;
              return Opacity(
                opacity: enabled ? 1 : 0.45,
                child: IgnorePointer(
                  ignoring: !enabled,
                  child: DfFilterPill(
                    label: CurrencyFormatter.format(amount),
                    selected: false,
                    accentColor: AppColors.brandBlue,
                    onSelected: () => onAmountTap(amount),
                  ),
                ),
              );
            }).toList(growable: false),
          ),
          if (selectedPlatform.value == null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text(
                'Selecione o app para liberar os valores.',
                style: AppTypography.iosFootnote(theme.brightness).copyWith(
                  color: AppColors.secondaryLabel(theme),
                ),
              ),
            ),
          if (mutation.hasError) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              FailureMessage.forObject(mutation.error),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push(AppRoutes.earningForm);
            },
            child: const Text('Formulário completo'),
          ),
        ],
      ),
    );
  }
}
