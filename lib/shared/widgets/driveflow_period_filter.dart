import 'package:flutter/material.dart';

import '../../core/constants/date_range_period.dart';
import 'design_system/df_segmented_control.dart';

/// Filtro de período premium — DfSegmentedControl.
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
      child: DfSegmentedControl<DateRangePeriod>(
        segments: DateRangePeriod.values,
        selected: value,
        onChanged: onChanged,
        labelBuilder: (p) => p.label,
      ),
    );
  }
}
