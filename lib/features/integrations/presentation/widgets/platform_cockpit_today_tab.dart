import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../shift/presentation/providers/shift_session_providers.dart';
import '../../../shift/presentation/widgets/active_shift_banner.dart';
import '../providers/integrations_providers.dart';
import 'platform_golden_hour_card.dart';
import 'platform_payout_calendar_card.dart';
import 'platform_profit_per_km_card.dart';
import 'platform_recommendation_hero_card.dart';
import 'platform_score_card.dart';

/// Aba Hoje — decisão imediata e caixa.
class PlatformCockpitTodayTab extends ConsumerWidget {
  const PlatformCockpitTodayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recommendation = ref.watch(platformShiftRecommendationProvider);
    final missing = ref.watch(missingSyncPlatformsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ActiveShiftBanner(),
        const SizedBox(height: AppSpacing.md),
        recommendation.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (rec) => rec == null
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PlatformRecommendationHeroCard(recommendation: rec),
                    if (ref.watch(activeShiftSessionProvider).valueOrNull ==
                        null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      DfButton(
                        label: 'Iniciar turno agora',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () => context.push(AppRoutes.shiftMode),
                      ),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        const PlatformGoldenHourCard(),
        const SizedBox(height: AppSpacing.md),
        const PlatformScoreCard(),
        const SizedBox(height: AppSpacing.md),
        const PlatformProfitPerKmCard(),
        const SizedBox(height: AppSpacing.md),
        const PlatformPayoutCalendarCard(),
        if (missing.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          DfCard(
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  color: AppColors.warningAmber,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Apps conectados sem dados recentes: '
                    '${missing.map((p) => p.label).join(', ')}.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryLabel(theme),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
