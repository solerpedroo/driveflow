import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/platform_golden_hour_slot.dart';
import '../providers/platform_intelligence_providers.dart';

/// Card de horário de ouro cross-platform.
class PlatformGoldenHourCard extends ConsumerWidget {
  const PlatformGoldenHourCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final slot = ref.watch(platformGoldenHourProvider).valueOrNull;
    if (slot == null) return const SizedBox.shrink();

    return DfCard(
      variant: DfCardVariant.hero,
      child: _Content(slot: slot, theme: theme),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.slot, required this.theme});

  final PlatformGoldenHourSlot slot;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.schedule_rounded, color: AppColors.warningAmber),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Horário de ouro: ${slot.platform.label}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${slot.weekdayLabel} ${slot.hourLabel} · '
                '${CurrencyFormatter.format(slot.avgPayoutPerHour)}/h · '
                '${slot.tripCount} corridas',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryLabel(theme),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
