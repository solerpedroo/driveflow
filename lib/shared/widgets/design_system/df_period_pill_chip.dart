import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Chip de período estilo Mescla — pílula com lavado brand no selecionado.
class DfPeriodPillChip extends StatelessWidget {
  const DfPeriodPillChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
    this.accentColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = accentColor ?? AppColors.brandBlue;
    final muted = AppColors.mutedSurface(theme);

    return Material(
      color: selected
          ? primary.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.22 : 0.12,
            )
          : muted,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: selected ? primary : AppColors.secondaryLabel(theme),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Fileira horizontal de chips de período — padrão Mescla unificado.
class DfPeriodPillRow<T> extends StatelessWidget {
  const DfPeriodPillRow({
    required this.segments,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
    super.key,
    this.accentColor,
    this.spacing = 8,
  });

  final List<T> segments;
  final T selected;
  final String Function(T segment) labelBuilder;
  final ValueChanged<T> onChanged;
  final Color? accentColor;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            DfPeriodPillChip(
              label: labelBuilder(segments[i]),
              selected: segments[i] == selected,
              accentColor: accentColor,
              onTap: () => onChanged(segments[i]),
            ),
          ],
        ],
      ),
    );
  }
}
