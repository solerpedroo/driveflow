import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/driveflow_glass_card.dart';
import '../../../../shared/widgets/driveflow_period_filter.dart';
import '../../domain/entities/earning_entity.dart';
import '../providers/earnings_providers.dart';

/// Listagem de ganhos com filtros de período e plataforma.
class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final period = ref.watch(earningsPeriodProvider);
    final platformFilter = ref.watch(earningsPlatformFilterProvider);
    final earningsAsync = ref.watch(earningsListProvider);
    final totalAsync = ref.watch(earningsTotalProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ganhos', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  DriveFlowPeriodFilter(
                    value: period,
                    onChanged: (p) =>
                        ref.read(earningsPeriodProvider.notifier).state = p,
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Todas'),
                          selected: platformFilter == null,
                          onSelected: (_) => ref
                              .read(earningsPlatformFilterProvider.notifier)
                              .state = null,
                        ),
                        ...kRidePlatforms.map(
                          (platform) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: FilterChip(
                              label: Text(platform.label),
                              selected: platformFilter == platform,
                              onSelected: (_) => ref
                                  .read(earningsPlatformFilterProvider.notifier)
                                  .state = platform,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            sliver: SliverToBoxAdapter(
              child: DriveFlowGlassCard(
                child: Row(
                  children: [
                    const Icon(Icons.payments_outlined,
                        color: AppColors.profitGreen),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total no período',
                              style: theme.textTheme.labelMedium),
                          totalAsync.when(
                            loading: () => const Text('...'),
                            error: (e, _) => Text('Erro'),
                            data: (total) => Text(
                              CurrencyFormatter.format(total),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppColors.profitGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          earningsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Erro: $e')),
            ),
            data: (earnings) {
              if (earnings.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'Nenhum ganho neste período.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.secondaryLabel(theme),
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
                sliver: SliverList.separated(
                  itemCount: earnings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _EarningTile(earning: earnings[index]);
                  },
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.earningForm),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ganho'),
      ),
    );
  }
}

class _EarningTile extends ConsumerWidget {
  const _EarningTile({required this.earning});

  final EarningEntity earning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DriveFlowGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(AppRoutes.earningForm, extra: earning),
        onLongPress: () => _confirmDelete(context, ref),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    earning.platform.label,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateUtilsDriveFlow.dayMonthYear.format(earning.date)} · '
                    '${earning.rides} corridas · ${earning.workedHours}h',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryLabel(theme),
                    ),
                  ),
                  if (earning.note != null && earning.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      earning.note!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              CurrencyFormatter.format(earning.amount),
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.profitGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir ganho?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(earningsControllerProvider.notifier).delete(earning.id);
    }
  }
}
