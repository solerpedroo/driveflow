import 'package:flutter/material.dart';

import '../../../features/goals/domain/entities/goal_entity.dart';
import 'df_period_pill_chip.dart';

/// Chips de período de meta — Diária / Semanal / Mensal / Anual.
class DfGoalPeriodChips extends StatelessWidget {
  const DfGoalPeriodChips({
    required this.selected,
    required this.onChanged,
    super.key,
    this.useShortLabels = true,
  });

  final GoalPeriod selected;
  final ValueChanged<GoalPeriod> onChanged;
  final bool useShortLabels;

  @override
  Widget build(BuildContext context) {
    return DfPeriodPillRow<GoalPeriod>(
      segments: GoalPeriod.values,
      selected: selected,
      labelBuilder: (p) => useShortLabels ? p.shortLabel : p.label,
      onChanged: onChanged,
    );
  }
}
