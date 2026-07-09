import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_shortcut_tile.dart';

/// Carrossel horizontal de atalhos — padrão FitFolio quick actions.
class DashboardShortcutsRow extends StatelessWidget {
  const DashboardShortcutsRow({super.key});

  static const _shortcuts = [
    _Shortcut(Icons.insights_outlined, 'Análises', AppRoutes.analytics),
    _Shortcut(Icons.auto_awesome_outlined, 'Insights', AppRoutes.insights),
    _Shortcut(Icons.smart_toy_outlined, 'IA', AppRoutes.aiChat),
    _Shortcut(Icons.flag_outlined, 'Metas', AppRoutes.goals),
    _Shortcut(Icons.upload_file_outlined, 'Importar', AppRoutes.importStatement),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Text(
            'Acesso rápido',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 118,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: _shortcuts.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final item = _shortcuts[index];
              return DfShortcutTile(
                icon: item.icon,
                label: item.label,
                onTap: () => context.push(item.route),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Shortcut {
  const _Shortcut(this.icon, this.label, this.route);

  final IconData icon;
  final String label;
  final String route;
}
