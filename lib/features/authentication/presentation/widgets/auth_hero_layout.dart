import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/driveflow_brand_logo.dart';
import '../../../../shared/widgets/driveflow_gradient_background.dart';

/// Layout auth editorial — hero headline + form card sobreposto (FitCal pattern).
class AuthHeroLayout extends StatelessWidget {
  const AuthHeroLayout({
    required this.headline,
    required this.subtitle,
    required this.formChild,
    super.key,
    this.showLogo = true,
    this.footer,
    this.leading,
  });

  final String headline;
  final String subtitle;
  final Widget formChild;
  final bool showLogo;
  final Widget? footer;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DriveFlowGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: leading != null
            ? AppBar(
                backgroundColor: Colors.transparent,
                leading: leading,
              )
            : null,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  AppSpacing.xxl,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showLogo) ...[
                        const DriveFlowBrandLogo(
                          size: LogoSize.small,
                          showTagline: false,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                      Text(
                        headline,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.secondaryLabel(theme),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      DfCard(
                        variant: DfCardVariant.elevated,
                        child: formChild,
                      ),
                      if (footer != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        footer!,
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
