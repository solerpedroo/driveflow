import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../integrations/domain/entities/platform_goal_progress.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../providers/platform_analytics_providers.dart';

/// Progresso da meta diária por Uber/99/InDrive.
class PlatformGoalProgressCard extends ConsumerWidget {
  const PlatformGoalProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(platformGoalProgressProvider);

    return progress.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();

        final brightness = Theme.of(context).brightness;

        return DfCard(
          variant: DfCardVariant.elevated,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meta por app',
                style: AppTypography.labelCaps(brightness),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 20,
                    thickness: 0.5,
                    color: AppElevation.hairline(brightness).color,
                  ),
                _ProgressRow(item: items[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.item});

  final PlatformGoalProgress item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final value = (item.progressPercent / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.platform.label,
                style: AppTypography.iosHeadline(brightness).copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${CurrencyFormatter.format(item.actualAmount)} / '
              '${CurrencyFormatter.format(item.targetAmount)}',
              style: AppTypography.iosCaption(brightness).copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 7,
            backgroundColor: AppColors.brandBlue.withValues(alpha: 0.10),
            color: AppColors.brandBlue,
          ),
        ),
      ],
    );
  }
}
