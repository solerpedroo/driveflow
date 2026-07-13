import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/platform_cockpit_tab.dart';
import '../platform_cockpit_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../integrations/domain/entities/platform_shift_plan.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../../shift/presentation/providers/shift_session_providers.dart';
import '../providers/platform_analytics_providers.dart';

/// Timeline do plano de turno sugerido.
class PlatformShiftPlanCard extends ConsumerWidget {
  const PlatformShiftPlanCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plan = ref.watch(platformShiftPlanProvider);

    return plan.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();

        return DfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plano de turno',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Projeção ${CurrencyFormatter.format(data.projectedRevenue)} '
                'em ${data.totalHours}h',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryLabel(theme),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final block in data.blocks)
                _BlockRow(
                  block: block,
                  onTap: () {
                    DfHaptics.light();
                    context.push(PlatformCockpitRoutes.hub(
                      tab: PlatformCockpitTab.shift,
                    ));
                  },
                ),
              const SizedBox(height: AppSpacing.md),
              ref.watch(activeShiftSessionProvider).valueOrNull == null
                  ? DfButton(
                      label: 'Iniciar turno com este plano',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () async {
                        DfHaptics.medium();
                        final isTaxi = ref.read(isTaxiDriverProvider);
                        final created = await ref
                            .read(shiftSessionControllerProvider.notifier)
                            .start(plan: data, isTaxiMode: isTaxi);
                        if (!context.mounted) return;
                        if (created != null) {
                          context.push(AppRoutes.shiftMode);
                        }
                      },
                    )
                  : DfButton(
                      label: 'Ver turno ativo',
                      variant: DfButtonVariant.tonal,
                      icon: Icons.timer_rounded,
                      onPressed: () => context.push(AppRoutes.shiftMode),
                    ),
            ],
          ),
        );
      },
    );
  }
}

class _BlockRow extends StatelessWidget {
  const _BlockRow({
    required this.block,
    this.onTap,
  });

  final PlatformShiftPlanBlock block;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.skyBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${block.timeRange} · ${block.platform.label}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      block.reason,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.secondaryLabel(theme),
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.secondaryLabel(theme),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
