import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_elevation.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// Linha de movimentação — row flat (Wallet), sem card por item.
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
    final displayAmount = hideValue ? 'R\$ ••••' : amount;

    return Material(
      color: AppColors.secondaryGrouped(brightness),
      borderRadius: AppRadius.grouped,
      child: InkWell(
        borderRadius: AppRadius.grouped,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              leading ??
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.fromBorderSide(
                        AppElevation.hairline(brightness),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      symbol,
                      style: theme.textTheme.titleLarge?.copyWith(
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detailCaps,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryLabel(theme),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      dateLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryLabel(theme),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                displayAmount,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
