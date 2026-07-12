import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../maintenance/domain/entities/maintenance_entity.dart';
import '../../../maintenance/presentation/providers/maintenance_providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
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
    final brightness = theme.brightness;
    final first = alerts.first;
    final isOverdue = first.status == MaintenanceDueStatus.overdue;

    return DfCard(
      variant: DfCardVariant.elevated,
      onTap: () => context.push(AppRoutes.maintenanceHistory),
      semanticLabel: 'Manutenção pendente',
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.warningAmber.withValues(alpha: 0.14),
            ),
            child: const Icon(
              Icons.build_circle_outlined,
              color: AppColors.warningAmber,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Manutenção pendente',
                        style: AppTypography.labelCaps(brightness),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.expenseCoral.withValues(alpha: 0.12),
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Text(
                        '${alerts.length}',
                        style: AppTypography.iosCaption(brightness).copyWith(
                          color: AppColors.expenseCoral,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  first.record.type.label,
                  style: AppTypography.iosHeadline(brightness).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  first.status.label,
                  style: AppTypography.iosFootnote(brightness).copyWith(
                    color: isOverdue
                        ? AppColors.expenseCoral
                        : AppColors.warningAmber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.secondaryLabel(theme).withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }
}
