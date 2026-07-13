import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_empty_state.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';
import '../../../../shared/widgets/platform_brand_icon.dart';
import '../providers/shift_history_providers.dart';
import '../widgets/shift_adherence_badge.dart';
import '../widgets/shift_timer_widget.dart';

/// Retrospectiva detalhada de um turno encerrado.
class ShiftRetrospectiveScreen extends ConsumerWidget {
  const ShiftRetrospectiveScreen({required this.entryId, super.key});

  final String entryId;

  static final _timeFormat = DateFormat('HH:mm', 'pt_BR');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retrospectiveAsync = ref.watch(shiftRetrospectiveProvider(entryId));
    final exportState = ref.watch(shiftRetrospectiveExportControllerProvider);
    final hidden = ref.watch(valueVisibilityHiddenProvider);

    return retrospectiveAsync.when(
      loading: () => const DfSubpageScaffold(
        title: 'Retrospectiva',
        children: [
          DfSkeleton(itemCount: 3),
        ],
      ),
      error: (_, __) => DfSubpageScaffold(
        title: 'Retrospectiva',
        children: [
          DfEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Não foi possível carregar',
            subtitle: 'Tente voltar e abrir de novo.',
            actionLabel: 'Voltar',
            onAction: () => context.pop(),
          ),
        ],
      ),
      data: (retrospective) {
        if (retrospective == null) {
          return DfSubpageScaffold(
            title: 'Retrospectiva',
            children: [
              DfEmptyState(
                icon: Icons.history_rounded,
                title: 'Turno não encontrado',
                subtitle: 'Esse registro pode ter sido removido ou ainda não sincronizou.',
                actionLabel: 'Ver histórico',
                onAction: () => context.pop(),
              ),
            ],
          );
        }

        final entry = retrospective.entry;
        final theme = Theme.of(context);
        final hasSnapshot = entry.blockOutcomes.isNotEmpty;

        return DfSubpageScaffold(
          title: 'Retrospectiva',
          children: [
            DfCard(
              variant: DfCardVariant.hero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hidden
                        ? '•••'
                        : CurrencyFormatter.format(entry.revenue),
                    style:
                        AppTypography.iosLargeTitle(theme.brightness).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${DateUtilsDriveFlow.dayMonthYear.format(entry.startedAt)} · '
                    '${_timeFormat.format(entry.startedAt)}–${_timeFormat.format(entry.endedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryLabel(theme),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ShiftTimerWidget.format(entry.elapsed)} · ${entry.rides} corridas',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryLabel(theme),
                    ),
                  ),
                  if (entry.revenuePerHour != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      hidden
                          ? '•••/h'
                          : '${CurrencyFormatter.format(entry.revenuePerHour!)}/h',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.brandBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Insight',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (entry.totalPlanBlocks > 0)
                        ShiftAdherenceBadge(score: entry.adherenceScore),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    retrospective.insight,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
            if (retrospective.platformBreakdown.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              DfCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mix por app',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    for (final slice in retrospective.platformBreakdown)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          children: [
                            if (PlatformBrandIcon.hasBrandAsset(slice.platform))
                              PlatformBrandIcon(
                                platform: slice.platform,
                                size: 24,
                                borderRadius: 6,
                              ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: Text(slice.platform.label)),
                            Text(
                              hidden
                                  ? '•••'
                                  : CurrencyFormatter.format(slice.revenue),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '${(slice.share * 100).round()}%',
                              style: AppTypography.iosFootnote(theme.brightness),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (retrospective.blockOutcomes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              DfCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plano vs realizado',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (hasSnapshot) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Snapshot do encerramento — não muda se você editar ganhos depois.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryLabel(theme),
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    for (final outcome in retrospective.blockOutcomes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              outcome.matched
                                  ? Icons.check_circle_rounded
                                  : Icons.swap_horiz_rounded,
                              color: outcome.matched
                                  ? AppColors.profitGreen
                                  : AppColors.warningAmber,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${outcome.block.timeRange} · '
                                    '${outcome.block.platform.label}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    outcome.actualPlatform == null
                                        ? 'Sem ganhos no bloco'
                                        : 'Real: ${outcome.actualPlatform!.label} · '
                                            '${hidden ? '•••' : CurrencyFormatter.format(outcome.revenue)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.secondaryLabel(theme),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            DfButton(
              label: 'Exportar PDF',
              icon: Icons.picture_as_pdf_outlined,
              variant: DfButtonVariant.outlined,
              isLoading: exportState.isLoading,
              onPressed: exportState.isLoading
                  ? null
                  : () => ref
                      .read(shiftRetrospectiveExportControllerProvider.notifier)
                      .exportPdf(retrospective),
            ),
            const SizedBox(height: AppSpacing.sm),
            DfButton(
              label: 'Voltar ao histórico',
              variant: DfButtonVariant.tonal,
              onPressed: () => context.pop(),
            ),
          ],
        );
      },
    );
  }
}
