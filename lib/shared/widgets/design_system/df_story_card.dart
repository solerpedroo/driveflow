import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/df_haptics.dart';

/// Card narrativo — métrica + história que vende o valor do produto.
class DfStoryCard extends StatefulWidget {
  const DfStoryCard({
    required this.label,
    required this.value,
    required this.narrative,
    required this.icon,
    required this.accentColor,
    super.key,
    this.onTap,
  });

  final String label;
  final String value;
  final String narrative;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  State<DfStoryCard> createState() => _DfStoryCardState();
}

class _DfStoryCardState extends State<DfStoryCard> {
  bool _pressed = false;

  void _handleTap() {
    DfHaptics.light();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '${widget.label}: ${widget.value}. ${widget.narrative}',
      button: widget.onTap != null,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: DriveFlowMotion.fast,
          curve: DriveFlowMotion.standard,
          child: Container(
            width: 168,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: AppRadius.lgAll,
              color: widget.accentColor.withValues(alpha: 0.08),
              border: Border.all(
                color: widget.accentColor.withValues(alpha: 0.20),
              ),
              boxShadow: _pressed
                  ? [
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.16),
                    borderRadius: AppRadius.smAll,
                  ),
                  child: Icon(widget.icon, size: 20, color: widget.accentColor),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  widget.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: widget.accentColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.narrative,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                    height: 1.35,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
