import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/product_story.dart';
import '../../../../shared/widgets/design_system/df_value_banner.dart';

/// Banner Pro no perfil — reutiliza o mesmo componente do dashboard.
class ProfilePlanCard extends StatelessWidget {
  const ProfilePlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DfValueBanner(
      variant: DfValueBannerVariant.pro,
      icon: Icons.workspace_premium_rounded,
      title: ProductStory.proHeadline,
      subtitle: ProductStory.proSubtitle,
      actionLabel: 'Conhecer o Pro',
      onAction: () => context.push(AppRoutes.paywall),
    );
  }
}
