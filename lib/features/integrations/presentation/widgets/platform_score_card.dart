import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../providers/platform_intelligence_providers.dart';

/// Ranking de score composto por plataforma.
class PlatformScoreCard extends ConsumerWidget {
  const PlatformScoreCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scores = ref.watch(platformScoreProvider).valueOrNull ?? [];
    if (scores.isEmpty) return const SizedBox.shrink();

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score por plataforma',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final score in scores.take(3)) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    score.platform.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  score.score.toStringAsFixed(0),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.profitGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  score.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                  ),
                ),
              ],
            ),
            Text(
              '${CurrencyFormatter.format(score.avgPerHour)}/h · '
              'taxa ${score.takeRatePercent.toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.secondaryLabel(theme),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
