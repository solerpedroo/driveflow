import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/platform_cockpit_tab.dart';
import '../platform_cockpit_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../integrations/domain/entities/platform_shift_plan.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
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
