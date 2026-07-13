import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../integrations/presentation/widgets/platform_heatmap_widget.dart';

/// Seção de heatmap por app na tela de Análises.
class AnalyticsPlatformHeatmapSection extends ConsumerWidget {
  const AnalyticsPlatformHeatmapSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: AppSpacing.md),
        PlatformHeatmapWidget(),
      ],
    );
  }
}
