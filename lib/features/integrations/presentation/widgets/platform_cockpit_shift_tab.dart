import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'platform_heatmap_widget.dart';
import 'platform_mix_simulator_card.dart';
import 'platform_shift_plan_card.dart';

/// Aba Turno — heatmap, plano e simulador de mix.
class PlatformCockpitShiftTab extends StatelessWidget {
  const PlatformCockpitShiftTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlatformHeatmapWidget(),
        SizedBox(height: AppSpacing.md),
        PlatformShiftPlanCard(),
        SizedBox(height: AppSpacing.md),
        PlatformMixSimulatorCard(),
      ],
    );
  }
}
