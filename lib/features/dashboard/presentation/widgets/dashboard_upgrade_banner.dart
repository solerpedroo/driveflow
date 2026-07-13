import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/product_story.dart';
import '../../../../shared/widgets/design_system/df_value_banner.dart';

/// Banner contextual de upsell Pro no dashboard.
class DashboardUpgradeBanner extends StatelessWidget {
  const DashboardUpgradeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return DfValueBanner(
      title: ProductStory.proHeadline,
      subtitle: ProductStory.proDashboardSubtitle,
      icon: Icons.workspace_premium_rounded,
      variant: DfValueBannerVariant.insight,
      actionLabel: 'Conhecer o Pro',
      onAction: () => context.push(AppRoutes.paywall),
    );
  }
}
