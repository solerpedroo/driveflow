import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import 'df_card.dart';

/// Linha de movimentação estilo Mescla — +/- , caps, valor, ver detalhes.
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
    final color = isCredit ? AppColors.profitGreen : AppColors.expenseCoral;
    final symbol = isCredit ? '+' : '−';
    final displayAmount = hideValue ? 'R\$ ••••' : amount;

    return DfCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: InkWell(
        borderRadius: AppRadius.grouped,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leading ??
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    symbol,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detailCaps.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.secondaryLabel(theme),
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryLabel(theme),
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Ver detalhes',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.brandBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              displayAmount,
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
