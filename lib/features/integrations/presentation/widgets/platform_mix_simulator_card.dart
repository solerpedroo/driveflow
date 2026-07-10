import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../providers/platform_analytics_providers.dart';

/// Simulador de mix Uber/99/InDrive com projeção mensal.
class PlatformMixSimulatorCard extends ConsumerWidget {
  const PlatformMixSimulatorCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final uber = ref.watch(platformMixUberProvider);
    final ninetyNine = ref.watch(platformMix99Provider);
    final inDrive = ref.watch(platformMixInDriveProvider);
    final simulation = ref.watch(platformMixSimulationProvider);

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Simulador de mix',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _MixSlider(
            label: RidePlatform.uber.label,
            value: uber,
            onChanged: (v) =>
                ref.read(platformMixUberProvider.notifier).state = v,
          ),
          _MixSlider(
            label: RidePlatform.ninetyNine.label,
            value: ninetyNine,
            onChanged: (v) =>
                ref.read(platformMix99Provider.notifier).state = v,
          ),
          _MixSlider(
            label: RidePlatform.inDrive.label,
            value: inDrive,
            onChanged: (v) =>
                ref.read(platformMixInDriveProvider.notifier).state = v,
          ),
          const SizedBox(height: AppSpacing.md),
          simulation.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (sim) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lucro mensal estimado: '
                  '${CurrencyFormatter.format(sim.projectedMonthlyProfit)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.profitGreen,
                  ),
                ),
                Text(
                  'Melhor app histórico: ${sim.bestPlatform.label}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MixSlider extends StatelessWidget {
  const _MixSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(label, style: Theme.of(context).textTheme.labelSmall),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 20,
            label: '${value.round()}%',
            onChanged: onChanged,
          ),
        ),
        Text('${value.round()}%'),
      ],
    );
  }
}
