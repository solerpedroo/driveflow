import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/driveflow_glass_card.dart';

/// Placeholder para abas ainda não implementadas (Ondas 3+).
class DriveFlowTabPlaceholder extends StatelessWidget {
  const DriveFlowTabPlaceholder({
    required this.title,
    required this.description,
    required this.icon,
    this.waveLabel,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? waveLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: SliverToBoxAdapter(
            child: Text(title, style: theme.textTheme.headlineSmall),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          sliver: SliverToBoxAdapter(
            child: DriveFlowGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 36, color: AppColors.electricTeal),
                  const SizedBox(height: 16),
                  Text(description, style: theme.textTheme.bodyLarge),
                  if (waveLabel != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      waveLabel!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.electricTeal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
