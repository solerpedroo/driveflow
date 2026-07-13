import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/services/platform_profit_per_km_analyzer.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../providers/platform_intelligence_providers.dart';

/// Lucro líquido por km rodado em cada app conectado.
class PlatformProfitPerKmCard extends ConsumerWidget {
  const PlatformProfitPerKmCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final snapshots = ref.watch(platformProfitPerKmProvider);

    return snapshots.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        final withData = data.where((s) => s.hasData).toList();
        if (withData.isEmpty) return const SizedBox.shrink();

        return DfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lucro por km',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Repasse líquido menos combustível estimado',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryLabel(theme),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final snapshot in withData)
                _Row(snapshot: snapshot),
            ],
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.snapshot});

  final PlatformProfitPerKmSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final positive = snapshot.profitPerKm >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              snapshot.platform.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${CurrencyFormatter.format(snapshot.profitPerKm)}/km',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: positive ? AppColors.profitGreen : AppColors.expenseCoral,
            ),
          ),
        ],
      ),
    );
  }
}
