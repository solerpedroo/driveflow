import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/driveflow_brand_logo.dart';
import '../../../../shared/widgets/driveflow_gradient_background.dart';

/// Auth híbrido — grouped iOS + painel editorial ReuniAI.
class AuthHeroLayout extends StatelessWidget {
  const AuthHeroLayout({
    required this.headline,
    required this.subtitle,
    required this.formChild,
    super.key,
    this.showLogo = true,
    this.footer,
    this.leading,
    this.middleChild,
  });

  final String headline;
  final String subtitle;
  final Widget formChild;
  final bool showLogo;
  final Widget? footer;
  final Widget? leading;
  final Widget? middleChild;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

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
                      DfCard(
                        variant: DfCardVariant.hero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: AppColors.brandBlue.withValues(
                                      alpha: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'DRIVEFLOW',
                                  style: AppTypography.labelCaps(brightness),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              headline,
                              style: AppTypography.iosLargeTitle(brightness),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              subtitle,
                              style: AppTypography.iosBody(brightness).copyWith(
                                color: AppColors.secondaryLabel(
                                  Theme.of(context),
                                ),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (middleChild != null) ...[
                        const SizedBox(height: AppSpacing.xl),
                        middleChild!,
                      ],
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
