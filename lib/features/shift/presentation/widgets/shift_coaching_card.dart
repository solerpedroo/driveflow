import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../integrations/domain/entities/platform_shift_plan.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../domain/entities/shift_coach_insight.dart';
import '../providers/shift_coaching_providers.dart';
import '../providers/shift_coaching_providers.dart';
import '../providers/shift_session_providers.dart';

/// Card de coaching com sugestão adaptativa para o próximo turno.
class ShiftCoachingCard extends ConsumerWidget {
  const ShiftCoachingCard({
    super.key,
    this.showStartAction = true,
  });

  final bool showStartAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(shiftCoachInsightProvider);
    final plan = ref.watch(adaptiveShiftPlanProvider);
    final theme = Theme.of(context);

    if (insight == null && plan.valueOrNull?.isEmpty != false) {
      return const SizedBox.shrink();
    }

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 20,
                color: AppColors.brandBlue,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Sugestão para o próximo turno',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (insight != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              insight.headline,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              insight.detail,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryLabel(theme),
                height: 1.4,
              ),
            ),
            if (insight.tips.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              for (final tip in insight.tips.take(2))
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.brandBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          tip,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryLabel(theme),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
          plan.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (data) {
              if (data.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Plano adaptativo · '
                    '${CurrencyFormatter.format(data.projectedRevenue)} '
                    'em ${data.totalHours}h',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.brandBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final block in data.blocks.take(3))
                    _PlanRow(block: block),
                  if (data.blocks.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+${data.blocks.length - 3} blocos',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.secondaryLabel(theme),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          if (showStartAction) ...[
            const SizedBox(height: AppSpacing.md),
            _StartShiftButton(plan: plan),
          ],
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.block});

  final PlatformShiftPlanBlock block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '${block.timeRange} · ${block.platform.label}',
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}

class _StartShiftButton extends ConsumerWidget {
  const _StartShiftButton({required this.plan});

  final AsyncValue<PlatformShiftPlan> plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeShiftSessionProvider).valueOrNull;
    final mutation = ref.watch(shiftSessionControllerProvider);
    final isTaxi = ref.watch(isTaxiDriverProvider);

    if (active != null) {
      return DfButton(
        label: 'Ver turno ativo',
        variant: DfButtonVariant.tonal,
        icon: Icons.timer_rounded,
        onPressed: () => context.push(AppRoutes.shiftMode),
      );
    }

    return DfButton(
      label: 'Iniciar com plano sugerido',
      icon: Icons.play_arrow_rounded,
      isLoading: mutation.isLoading,
      onPressed: mutation.isLoading
          ? null
          : () async {
              DfHaptics.medium();
              final adaptivePlan = plan.valueOrNull;
              final created = await ref
                  .read(shiftSessionControllerProvider.notifier)
                  .start(plan: adaptivePlan, isTaxiMode: isTaxi);
              if (!context.mounted || created == null) return;
              context.push(AppRoutes.shiftMode);
            },
    );
  }
}
