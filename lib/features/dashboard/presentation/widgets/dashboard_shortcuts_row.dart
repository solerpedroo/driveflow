import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_button.dart';

/// Atalhos rápidos para Análises e Insights.
class DashboardShortcutsRow extends StatelessWidget {
  const DashboardShortcutsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Row(
        children: [
          Expanded(
            child: DfButton(
              label: 'Análises',
              icon: Icons.insights_outlined,
              variant: DfButtonVariant.tonal,
              expand: true,
              onPressed: () => context.push(AppRoutes.analytics),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: DfButton(
              label: 'Insights',
              icon: Icons.auto_awesome_outlined,
              variant: DfButtonVariant.tonal,
              expand: true,
              onPressed: () => context.push(AppRoutes.insights),
            ),
          ),
        ],
      ),
    );
  }
}
