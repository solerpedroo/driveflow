import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/earning_time_slot.dart';
import '../../domain/entities/maintenance_prediction.dart';

/// Resumo compacto de insights — módulo elevado.
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
    final brightness = theme.brightness;
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
        scale: _pressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: DfCard(
          variant: DfCardVariant.elevated,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandBlue.withValues(alpha: 0.10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.brandBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dicas do dia',
                      style: AppTypography.labelCaps(brightness),
                    ),
                    const SizedBox(height: 4),
                    if (widget.topSlots.isNotEmpty)
                      Text(
                        'Melhor janela · ${widget.topSlots.first.weekdayLabel} '
                        '${widget.topSlots.first.hourLabel}',
                        style: AppTypography.iosHeadline(brightness).copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    if (widget.topSlots.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${CurrencyFormatter.format(widget.topSlots.first.profitPerHour)}/h em média',
                        style: AppTypography.iosFootnote(brightness),
                      ),
                    ],
                    if (widget.topPrediction != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        widget.topPrediction!.summaryLabel,
                        style: AppTypography.iosFootnote(brightness).copyWith(
                          color: AppColors.warningAmber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.secondaryLabel(theme).withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
