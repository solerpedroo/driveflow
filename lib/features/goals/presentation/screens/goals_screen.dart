import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/goal_entity.dart';
import '../providers/goals_providers.dart';
import '../../../../shared/widgets/design_system/df_form_scaffold.dart';
import '../../../../shared/widgets/design_system/df_hero_wealth_card.dart';
import '../../../../shared/widgets/design_system/df_section_header.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_text_field.dart';
import '../widgets/goal_progress_card.dart';
import '../widgets/goals_story_header.dart';

/// Metas financeiras — DfFormScaffold com hero de progresso + formulário.
class GoalsScreen extends HookConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final goalsAsync = ref.watch(goalsStreamProvider);
    final progressAsync = ref.watch(allGoalProgressProvider);
    final mutation = ref.watch(goalsControllerProvider);
    final formKey = useMemoized(GlobalKey<FormState>.new);

    final dailyController = useTextEditingController();
    final weeklyController = useTextEditingController();
    final monthlyController = useTextEditingController();
    final yearlyController = useTextEditingController();
    final seeded = useState(false);

    useEffect(() {
      final goals = goalsAsync.valueOrNull;
      if (goals != null && !seeded.value) {
        dailyController.text =
            goals.daily > 0 ? CurrencyFormatter.format(goals.daily) : '';
        weeklyController.text =
            goals.weekly > 0 ? CurrencyFormatter.format(goals.weekly) : '';
        monthlyController.text =
            goals.monthly > 0 ? CurrencyFormatter.format(goals.monthly) : '';
        yearlyController.text =
            goals.yearly > 0 ? CurrencyFormatter.format(goals.yearly) : '';
        seeded.value = true;
      }
      return null;
    }, [goalsAsync.valueOrNull?.updatedAt, goalsAsync.valueOrNull?.id]);

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      final draft = GoalDraft(
        daily: CurrencyFormatter.tryParse(dailyController.text) ?? 0,
        weekly: CurrencyFormatter.tryParse(weeklyController.text) ?? 0,
        monthly: CurrencyFormatter.tryParse(monthlyController.text) ?? 0,
        yearly: CurrencyFormatter.tryParse(yearlyController.text) ?? 0,
      );

      final saved =
          await ref.read(goalsControllerProvider.notifier).save(draft);
      if (saved != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Metas salvas com sucesso')),
        );
      }
    }

    return DfFormScaffold(
      title: 'Metas',
      submitLabel: 'Salvar metas',
      isLoading: mutation.isLoading,
      onSubmit: submit,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GoalsStoryHeader(),
            progressAsync.when(
              loading: () => const DfSkeleton(itemCount: 1),
              error: (_, __) => const SizedBox.shrink(),
              data: (progressMap) {
                final monthly = progressMap[GoalPeriod.monthly];
                if (monthly == null) return const SizedBox.shrink();
                return DfHeroWealthCard(
                  label: 'Meta mensal',
                  value: monthly.hasTarget
                      ? CurrencyFormatter.format(monthly.targetAmount)
                      : 'Sem meta',
                  badge: monthly.progressLabel,
                );
              },
            ),
            const DfSectionHeader(title: 'Progresso', eyebrow: 'Períodos'),
            progressAsync.when(
              loading: () => const DfSkeleton(itemCount: 3),
              error: (e, _) => Text('Erro: $e'),
              data: (progressMap) => Column(
                children: [
                  for (final period in GoalPeriod.values)
                    if (progressMap[period] case final progress?) ...[
                      GoalProgressCard(progress: progress),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
            ),
            const DfSectionHeader(title: 'Configurar metas', eyebrow: 'Valores'),
            Text(
              'Defina quanto você quer lucrar em cada período (ganhos − despesas).',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryLabel(theme),
              ),
            ),
            const SizedBox(height: 16),
            DfTextField(
              controller: dailyController,
              label: 'Meta diária',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.today_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                return Validators.brlAmount(v);
              },
            ),
            const SizedBox(height: 12),
            DfTextField(
              controller: weeklyController,
              label: 'Meta semanal',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.date_range_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                return Validators.brlAmount(v);
              },
            ),
            const SizedBox(height: 12),
            DfTextField(
              controller: monthlyController,
              label: 'Meta mensal',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.calendar_month_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                return Validators.brlAmount(v);
              },
            ),
            const SizedBox(height: 12),
            DfTextField(
              controller: yearlyController,
              label: 'Meta anual',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.event_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                return Validators.brlAmount(v);
              },
            ),
            if (mutation.hasError) ...[
              const SizedBox(height: 12),
              Text(
                mutation.error.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
