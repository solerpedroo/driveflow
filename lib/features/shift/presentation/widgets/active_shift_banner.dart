import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/shift_session_status.dart';
import '../providers/shift_session_providers.dart';
import 'shift_earnings_summary.dart';
import 'shift_timer_widget.dart';

/// Banner compacto quando há turno ativo — dashboard e cockpit.
class ActiveShiftBanner extends ConsumerWidget {
  const ActiveShiftBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(activeShiftSessionProvider);
    final summary = ref.watch(shiftSessionSummaryProvider);
    final hidden = ref.watch(valueVisibilityHiddenProvider);

    return sessionAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (session) {
        if (session == null) return const SizedBox.shrink();

        final theme = Theme.of(context);

        return DfCard(
          variant: DfCardVariant.elevated,
          onTap: () {
            DfHaptics.light();
            context.push(AppRoutes.shiftMode);
          },
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Row(
            children: [
              Icon(
                session.status == ShiftSessionStatus.paused
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
                color: AppColors.brandBlue,
                size: 36,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.status == ShiftSessionStatus.paused
                          ? 'Turno pausado'
                          : 'Turno em andamento',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandBlue,
                      ),
                    ),
                    const SizedBox(height: 2),
                    LiveElapsedText(
                      session: session,
                      style: AppTypography.iosHeadline(
                        Theme.of(context).brightness,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (summary != null)
                      Text(
                        hidden
                            ? 'Ganhos •••'
                            : 'Ganhos ${CurrencyFormatter.format(summary.revenue)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.secondaryLabel(Theme.of(context)),
                            ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        );
      },
    );
  }
}
