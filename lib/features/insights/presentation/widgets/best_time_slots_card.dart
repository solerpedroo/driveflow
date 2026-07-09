import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/driveflow_glass_card.dart';
import '../../domain/entities/earning_time_slot.dart';

/// Card com as melhores janelas de lucro/hora.
class BestTimeSlotsCard extends StatelessWidget {
  const BestTimeSlotsCard({
    required this.slots,
    super.key,
  });

  final List<EarningTimeSlot> slots;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Melhores horários para trabalhar',
      child: DriveFlowGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule_rounded, color: AppColors.infoBlue),
                const SizedBox(width: 8),
                Text('Melhor horário', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            if (slots.isEmpty)
              Text(
                'Registre ganhos com horário para ver recomendações.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryLabel(theme),
                ),
              )
            else
              ...slots.map((slot) => _SlotRow(slot: slot)),
          ],
        ),
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.slot});

  final EarningTimeSlot slot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${slot.weekdayLabel} · ${slot.hourLabel}',
              style: theme.textTheme.bodyLarge,
            ),
          ),
          Text(
            '${CurrencyFormatter.format(slot.profitPerHour)}/h',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.profitGreen,
            ),
          ),
        ],
      ),
    );
  }
}
