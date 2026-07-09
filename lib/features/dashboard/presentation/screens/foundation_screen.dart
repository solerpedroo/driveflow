import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../shared/widgets/driveflow_brand_logo.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/driveflow_gradient_background.dart';
import '../../../../shared/widgets/driveflow_metric_chip.dart';

/// Tela foundation da Onda 0 — showcase do design system + status do projeto.
class FoundationScreen extends HookConsumerWidget {
  const FoundationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(authStateProvider).valueOrNull;
    final pulse = useAnimationController(
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    useEffect(() {
      SystemChrome.setSystemUIOverlayStyle(
        isDark ? AppColors.darkOverlay : AppColors.lightOverlay,
      );
      return null;
    }, [isDark]);

    final glow = useAnimation(
      CurvedAnimation(parent: pulse, curve: Curves.easeInOut),
    );

    return DriveFlowGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Expanded(child: DriveFlowBrandLogo(size: LogoSize.medium)),
                      if (user != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            avatar: CircleAvatar(
                              backgroundColor:
                                  AppColors.electricTeal.withValues(alpha: 0.2),
                              child: Text(
                                user.displayName.characters.first.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.electricTeal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            label: Text(user.displayName),
                          ),
                        ),
                      IconButton.filledTonal(
                        tooltip: 'Alternar tema',
                        onPressed: () =>
                            ref.read(themeModeProvider.notifier).toggle(),
                        icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: DfCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _PulseDot(animation: glow),
                            const SizedBox(width: 8),
                            Text(
                              'FUNDAÇÃO PRONTA',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.electricTeal,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Olá, ${user?.displayName ?? 'motorista'}! Onda $kFoundationWave concluída — auth ativa.',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Arquitetura Clean + Feature First, Supabase versionado, '
                          'design system cockpit e roteamento GoRouter operacionais.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.secondaryLabel(theme),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Prévia de métricas',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.65,
                  ),
                  delegate: SliverChildListDelegate.fixed([
                    const DriveFlowMetricChip(
                      label: 'Lucro hoje',
                      value: 'R\$ 248,50',
                      accentColor: AppColors.profitGreen,
                      icon: Icons.trending_up_rounded,
                    ),
                    const DriveFlowMetricChip(
                      label: 'Custo / km',
                      value: 'R\$ 0,42',
                      accentColor: AppColors.expenseCoral,
                      icon: Icons.route_rounded,
                    ),
                    DriveFlowMetricChip(
                      label: 'Horas',
                      value: '6h 20m',
                      accentColor: AppColors.infoBlue,
                      icon: Icons.schedule_rounded,
                    ),
                    DriveFlowMetricChip(
                      label: 'Meta diária',
                      value: '72%',
                      accentColor: AppColors.warningAmber,
                      icon: Icons.flag_rounded,
                    ),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: DfCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stack MVP', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 12),
                        const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _TechPill('Flutter'),
                            _TechPill('Riverpod'),
                            _TechPill('GoRouter'),
                            _TechPill('Supabase'),
                            _TechPill('Hive'),
                            _TechPill('Groq IA'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.rocket_launch_rounded),
                        label: const Text('Próximo: Shell + Veículo (Onda 2)'),
                      ),
                      if (user != null) ...[
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () =>
                              ref.read(authControllerProvider.notifier).signOut(),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Sair'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot({required this.animation});

  final double animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.electricTeal.withValues(alpha: 0.5 + animation * 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricTeal.withValues(alpha: 0.35 + animation * 0.25),
            blurRadius: 8 + animation * 6,
          ),
        ],
      ),
    );
  }
}

class _TechPill extends StatelessWidget {
  const _TechPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.mutedSurface(theme),
        border: Border.all(
          color: AppColors.electricTeal.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium,
      ),
    );
  }
}
