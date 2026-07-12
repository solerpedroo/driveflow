import 'package:flutter/material.dart';

import '../../../core/utils/value_visibility_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_elevation.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Linha de movimentação — tile elevado no padrão Início.
class DfMovimentacaoTile extends StatelessWidget {
  const DfMovimentacaoTile({
    required this.title,
    required this.detailCaps,
    required this.dateLabel,
    required this.amount,
    required this.isCredit,
    super.key,
    this.onTap,
    this.onLongPress,
    this.hideValue = false,
    this.leading,
  });

  final String title;
  final String detailCaps;
  final String dateLabel;
  final String amount;
  final bool isCredit;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool hideValue;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final color = isCredit ? AppColors.profitGreen : AppColors.expenseCoral;
    final symbol = isCredit ? '+' : '−';
    final displayAmount =
        hideValue ? maskCurrency(amount, hidden: true) : amount;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.xlAll,
        border: Border.fromBorderSide(AppElevation.hairline(brightness)),
        boxShadow: AppElevation.surfaceCard(brightness),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.xlAll,
        child: InkWell(
          borderRadius: AppRadius.xlAll,
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                leading ??
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        symbol,
                        style: AppTypography.iosHeadline(brightness).copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.iosHeadline(brightness).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detailCaps,
                        style: AppTypography.iosFootnote(brightness).copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        dateLabel,
                        style: AppTypography.iosCaption(brightness),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  displayAmount,
                  style: AppTypography.iosHeadline(brightness).copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
