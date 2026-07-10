import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/product_story.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_hero_wealth_card.dart';
import '../../../../shared/widgets/design_system/df_section_header.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';

/// Paywall narrativo — layout Mescla com hero e features.
class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hidden = ref.watch(valueVisibilityHiddenProvider);

    return DfSubpageScaffold(
      title: 'DriveFlow Pro',
      valueHidden: hidden,
      onToggleValueVisibility: () => ref
          .read(valueVisibilityHiddenProvider.notifier)
          .state = !hidden,
      children: [
        Text(
          'Seu cockpit completo',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        Text(
          'Motoristas Pro tomam decisões mais rápidas com IA, previsões e importação automática.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.secondaryLabel(theme),
            height: 1.45,
          ),
        ),
        DfHeroWealthCard(
          label: 'Lucro médio Pro',
          value: 'R\$ 248',
          badge: 'por dia',
          hideValue: hidden,
        ),
        const DfSectionHeader(title: 'Recursos', eyebrow: 'Pro'),
        for (final feature in ProductStory.proFeatures) ...[
          _FeatureRow(
            icon: feature.icon,
            title: feature.title,
            body: feature.body,
          ),
        ],
        DfButton(
          label: 'Começar teste Pro — 7 dias grátis',
          icon: Icons.workspace_premium_rounded,
          variant: DfButtonVariant.gradient,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Assinaturas em breve — você será avisado primeiro.',
                ),
              ),
            );
          },
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Continuar com plano gratuito'),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DfCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.brandBlue.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.brandBlue, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
