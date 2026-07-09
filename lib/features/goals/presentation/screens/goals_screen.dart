import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../authentication/presentation/widgets/auth_primary_button.dart';
import '../../../authentication/presentation/widgets/auth_text_field.dart';
import '../../domain/entities/goal_entity.dart';
import '../providers/goals_providers.dart';
import '../widgets/goal_progress_card.dart';
import '../widgets/goals_story_header.dart';
import '../../../../shared/widgets/driveflow_glass_card.dart';

/// Tela de configuração e acompanhamento de metas financeiras.
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Metas'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          const GoalsStoryHeader(),
          const SizedBox(height: 20),
          Text('Progresso', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          progressAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
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
          const SizedBox(height: 24),
          Text('Configurar metas', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Defina quanto você quer lucrar em cada período (ganhos − despesas).',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryLabel(theme),
            ),
          ),
          const SizedBox(height: 16),
          DriveFlowGlassCard(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  AuthTextField(
                    controller: dailyController,
                    label: 'Meta diária',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: Icons.today_outlined,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      return Validators.brlAmount(v);
                    },
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: weeklyController,
                    label: 'Meta semanal',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: Icons.date_range_outlined,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      return Validators.brlAmount(v);
                    },
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: monthlyController,
                    label: 'Meta mensal',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: Icons.calendar_month_outlined,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      return Validators.brlAmount(v);
                    },
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: yearlyController,
                    label: 'Meta anual',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
                  const SizedBox(height: 16),
                  AuthPrimaryButton(
                    label: 'Salvar metas',
                    isLoading: mutation.isLoading,
                    onPressed: submit,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
