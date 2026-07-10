import 'package:flutter/material.dart';

import '../../core/constants/date_range_period.dart';
import 'design_system/df_period_pill_chip.dart';

/// Filtro de período — chips Mescla (Hoje / Semana / Mês).
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
    return DfPeriodPillRow<DateRangePeriod>(
      segments: DateRangePeriod.values,
      selected: value,
      labelBuilder: (p) => p.label,
      onChanged: onChanged,
    );
  }
}
