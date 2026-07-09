import 'package:flutter/material.dart';

import '../../../../core/utils/story_metrics.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/domain/models/period_summary.dart';
import '../../../goals/domain/services/goal_progress_calculator.dart';
import '../../../../shared/widgets/design_system/df_story_card.dart';

/// Carrossel de métricas narrativas — vende números e valor do produto.
class DashboardStorySection extends StatelessWidget {
  const DashboardStorySection({
    required this.today,
    required this.month,
    required this.goalProgress,
    super.key,
  });

  final PeriodSummary today;
  final PeriodSummary month;
  final GoalProgress goalProgress;

  @override
  Widget build(BuildContext context) {
    final cards = StoryMetrics.valueCards(
      today: today,
      month: month,
      goalProgress: goalProgress,
    );

    if (cards.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Text(
            'Seus números contam uma história',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 168,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final card = cards[index];
              return DfStoryCard(
                label: card.label,
                value: card.value,
                narrative: card.narrative,
                icon: card.icon,
                accentColor: card.accent,
              );
            },
          ),
        ),
      ],
    );
  }
}
