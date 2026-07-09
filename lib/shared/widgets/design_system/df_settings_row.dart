import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/df_haptics.dart';

/// Linha de atalho premium — ícone, label, chevron (padrão iOS Settings tier).
class DfSettingsRow extends StatefulWidget {
  const DfSettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
    this.subtitle,
    this.accentColor = AppColors.skyBlue,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Color accentColor;
  final bool showDivider;

  @override
  State<DfSettingsRow> createState() => _DfSettingsRowState();
}

class _DfSettingsRowState extends State<DfSettingsRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: widget.subtitle == null
              ? widget.label
              : '${widget.label}. ${widget.subtitle}',
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: () {
              DfHaptics.light();
              widget.onTap();
            },
            child: AnimatedScale(
              scale: _pressed ? 0.98 : 1.0,
              duration: DriveFlowMotion.fast,
              curve: DriveFlowMotion.standard,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.12),
                        borderRadius: AppRadius.mdAll,
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.accentColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.secondaryLabel(theme),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.secondaryLabel(theme)
                          .withValues(alpha: 0.55),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.showDivider)
          Divider(
            height: 1,
            color: theme.dividerColor.withValues(alpha: 0.35),
          ),
      ],
    );
  }
}
