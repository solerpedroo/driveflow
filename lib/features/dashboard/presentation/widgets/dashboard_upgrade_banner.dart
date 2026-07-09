import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/product_story.dart';
import '../../../../shared/widgets/design_system/df_value_banner.dart';

/// Banner Pro no dashboard — vende assinatura com features concretas.
class DashboardUpgradeBanner extends StatelessWidget {
  const DashboardUpgradeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: DfValueBanner(
        variant: DfValueBannerVariant.pro,
        icon: Icons.workspace_premium_rounded,
        title: ProductStory.proHeadline,
        subtitle: ProductStory.proSubtitle,
        actionLabel: 'Conhecer o Pro',
        onAction: () => context.push(AppRoutes.paywall),
      ),
    );
  }
}
