import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/earning_time_slot.dart';

/// Card premium com as melhores janelas de lucro/hora.
class BestTimeSlotsCard extends StatelessWidget {
  const BestTimeSlotsCard({
    required this.slots,
    super.key,
  });

  final List<EarningTimeSlot> slots;

  static const _rankColors = [
    AppColors.warningAmber,
    AppColors.skyBlueSoft,
    Color(0xFFCD7F32),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Melhores horários para trabalhar',
      child: DfCard(
        variant: slots.isNotEmpty ? DfCardVariant.elevated : DfCardVariant.glass,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.infoBlue.withValues(alpha: 0.14),
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    color: AppColors.infoBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Melhor horário',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (slots.isNotEmpty)
                  Text(
                    '${slots.length} janelas',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.secondaryLabel(theme),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (slots.isEmpty)
              Text(
                'Registre ganhos com horário para ver recomendações.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryLabel(theme),
                  height: 1.45,
                ),
              )
            else
              ...slots.asMap().entries.map(
                    (entry) => _SlotRow(
                      slot: entry.value,
                      rank: entry.key,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _SlotRow extends StatefulWidget {
  const _SlotRow({
    required this.slot,
    required this.rank,
  });

  final EarningTimeSlot slot;
  final int rank;

  @override
  State<_SlotRow> createState() => _SlotRowState();
}

class _SlotRowState extends State<_SlotRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showRank = widget.rank < 3;
    final rankColor = showRank
        ? BestTimeSlotsCard._rankColors[widget.rank]
        : AppColors.skyBlue;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: DfHaptics.light,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.mutedSurface(theme).withValues(alpha: 0.45),
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: rankColor.withValues(alpha: showRank ? 0.28 : 0.12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  if (showRank)
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: rankColor.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${widget.rank + 1}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: rankColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                  else
                    Icon(Icons.access_time_rounded,
                        size: 18, color: AppColors.secondaryLabel(theme)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${widget.slot.weekdayLabel} · ${widget.slot.hourLabel}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: showRank ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  Text(
                    '${CurrencyFormatter.format(widget.slot.profitPerHour)}/h',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.profitGreen,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
