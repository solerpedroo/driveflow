import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/earning_time_slot.dart';
import '../../domain/entities/maintenance_prediction.dart';

/// Resumo compacto de insights para o Dashboard — tap abre tela completa.
class DashboardInsightsSummary extends StatefulWidget {
  const DashboardInsightsSummary({
    required this.topSlots,
    required this.topPrediction,
    super.key,
  });

  final List<EarningTimeSlot> topSlots;
  final MaintenancePrediction? topPrediction;

  @override
  State<DashboardInsightsSummary> createState() =>
      _DashboardInsightsSummaryState();
}

class _DashboardInsightsSummaryState extends State<DashboardInsightsSummary> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasContent =
        widget.topSlots.isNotEmpty || widget.topPrediction != null;
    if (!hasContent) return const SizedBox.shrink();

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        DfHaptics.light();
        context.push(AppRoutes.insights);
      },
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: DfCard(
          variant: DfCardVariant.elevated,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.profitGreen, AppColors.skyBlue],
                      ),
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Dicas do dia',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.secondaryLabel(theme)
                        .withValues(alpha: 0.55),
                  ),
                ],
              ),
              if (widget.topSlots.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Melhor janela: ${widget.topSlots.first.weekdayLabel} '
                  '${widget.topSlots.first.hourLabel} · '
                  '${CurrencyFormatter.format(widget.topSlots.first.profitPerHour)}/h',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              if (widget.topPrediction != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.topPrediction!.summaryLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.warningAmber,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
