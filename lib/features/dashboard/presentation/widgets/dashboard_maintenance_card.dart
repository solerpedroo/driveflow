import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../maintenance/domain/entities/maintenance_entity.dart';
import '../../../maintenance/presentation/providers/maintenance_providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Card de alerta de manutenção pendente.
class DashboardMaintenanceCard extends StatelessWidget {
  const DashboardMaintenanceCard({
    required this.alerts,
    super.key,
  });

  final List<MaintenanceAlert> alerts;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final first = alerts.first;

    return DfCard(
      onTap: () => context.push(AppRoutes.maintenanceHistory),
      semanticLabel: 'Manutenção pendente',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.build_circle_outlined,
                  color: AppColors.warningAmber),
              const SizedBox(width: AppSpacing.sm),
              Text('Manutenção pendente', style: theme.textTheme.titleMedium),
              const Spacer(),
              Badge(
                label: Text('${alerts.length}'),
                backgroundColor: AppColors.expenseCoral,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(first.record.type.label, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            first.status.label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: first.status == MaintenanceDueStatus.overdue
                  ? AppColors.expenseCoral
                  : AppColors.warningAmber,
            ),
          ),
        ],
      ),
    );
  }
}
