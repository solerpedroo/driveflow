import 'package:flutter/material.dart';

import '../../core/constants/date_range_period.dart';
import '../../core/theme/app_colors.dart';

/// Chips de período (Hoje / Semana / Mês).
class DriveFlowPeriodFilter extends StatelessWidget {
  const DriveFlowPeriodFilter({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final DateRangePeriod value;
  final ValueChanged<DateRangePeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: DateRangePeriod.values.map((period) {
          final selected = period == value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(period.label),
              selected: selected,
              selectedColor: AppColors.electricTeal.withValues(alpha: 0.2),
              checkmarkColor: AppColors.electricTeal,
              onSelected: (_) => onChanged(period),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}
