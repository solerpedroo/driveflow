import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../integrations/domain/entities/platform_heatmap_slot.dart';
import '../../../integrations/domain/services/platform_analytics_breakdown.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_segmented_control.dart';
import '../providers/platform_analytics_providers.dart';

/// Heatmap 7×24 colorido por R$/h.
class PlatformHeatmapWidget extends ConsumerWidget {
  const PlatformHeatmapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filter = ref.watch(platformHeatmapFilterProvider);
    final slots = ref.watch(platformHeatmapProvider);

    return slots.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();

        final maxRate = data
            .map((s) => s.revenuePerHour)
            .reduce((a, b) => a > b ? a : b);

        return DfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Heatmap por app',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DfSegmentedControl<RidePlatform?>(
                  segments: [null, ...RidePlatform.values.where(
                    (p) => PlatformAnalyticsBreakdown.integratable.contains(p),
                  )],
                  selected: filter,
                  labelBuilder: (p) => p?.label ?? 'Todos',
                  onChanged: (p) =>
                      ref.read(platformHeatmapFilterProvider.notifier).state = p,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _HeatmapGrid(slots: data, maxRate: maxRate),
            ],
          ),
        );
      },
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  const _HeatmapGrid({required this.slots, required this.maxRate});

  final List<PlatformHeatmapSlot> slots;
  final double maxRate;

  static const _hours = [6, 8, 10, 12, 14, 16, 18, 20, 22];
  static const _weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lookup = {
      for (final s in slots) '${s.weekday}-${s.hour}': s,
    };

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 28),
            for (final h in _hours)
              Expanded(
                child: Text(
                  '${h}h',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall,
                ),
              ),
          ],
        ),
        for (var d = 1; d <= 7; d++) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(_weekdays[d - 1], style: theme.textTheme.labelSmall),
              ),
              for (final h in _hours)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(1),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _Cell(
                        slot: lookup['$d-$h'],
                        maxRate: maxRate,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.slot, required this.maxRate});

  final PlatformHeatmapSlot? slot;
  final double maxRate;

  @override
  Widget build(BuildContext context) {
    final intensity = slot != null && maxRate > 0
        ? (slot!.revenuePerHour / maxRate).clamp(0.1, 1.0)
        : 0.05;

    return Tooltip(
      message: slot == null
          ? 'Sem dados'
          : '${slot!.platform.label} ${slot!.revenuePerHour.toStringAsFixed(0)}/h',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.profitGreen.withValues(alpha: intensity),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}