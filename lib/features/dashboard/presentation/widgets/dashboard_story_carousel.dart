import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/story_metrics.dart';
import '../../../../shared/domain/models/period_summary.dart';
import '../../../goals/domain/services/goal_progress_calculator.dart';
import '../../../../shared/widgets/design_system/df_story_card.dart';

/// Carrossel horizontal de métricas narrativas no dashboard.
class DashboardStoryCarousel extends StatelessWidget {
  const DashboardStoryCarousel({
    required this.today,
    required this.month,
    required this.goal,
    super.key,
  });

  final PeriodSummary today;
  final PeriodSummary month;
  final GoalProgress goal;

  @override
  Widget build(BuildContext context) {
    final cards = StoryMetrics.valueCards(
      today: today,
      month: month,
      goalProgress: goal,
    );
    if (cards.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 188,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final card = cards[index];
          return DfStoryCard(
            label: card.label,
            value: card.value,
            narrative: card.narrative,
            icon: card.icon,
            accent: card.accent,
          );
        },
      ),
    );
  }
}
