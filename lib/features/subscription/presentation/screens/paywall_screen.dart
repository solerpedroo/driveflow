import 'package:flutter/material.dart';

import '../../../../core/constants/product_story.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/driveflow_gradient_background.dart';

/// Paywall narrativo — vende o Pro com storytelling e métricas de valor.
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DriveFlowGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('DriveFlow Pro'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
            AppSpacing.screenHorizontal,
            AppSpacing.xxxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Seu cockpit\ncompleto',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Motoristas Pro tomam decisões mais rápidas com IA, previsões e importação automática.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.secondaryLabel(theme),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              DfCard(
                variant: DfCardVariant.hero,
                child: Column(
                  children: [
                    Text(
                      'R\$ 248',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.profitGreen,
                      ),
                    ),
                    Text(
                      'lucro médio/dia de motoristas que usam metas + IA',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryLabel(theme),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              for (final feature in ProductStory.proFeatures) ...[
                _FeatureRow(
                  icon: feature.icon,
                  title: feature.title,
                  body: feature.body,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              const SizedBox(height: AppSpacing.lg),
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
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continuar com plano gratuito'),
              ),
            ],
          ),
        ),
      ),
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.skyBlue.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.skyBlue, size: 22),
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
    );
  }
}
