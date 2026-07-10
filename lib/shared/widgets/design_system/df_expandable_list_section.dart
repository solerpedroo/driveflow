import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../core/theme/app_spacing.dart';
import 'df_section_header.dart';

/// Seção com lista truncada e Ver todas / Ver menos (Mescla).
class DfExpandableListSection extends HookWidget {
  const DfExpandableListSection({
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.eyebrow,
    this.previewCount = 3,
    this.spacing = AppSpacing.sm,
    this.onSeeAll,
    this.seeAllLabel = 'Ver todas',
  });

  final String title;
  final String? eyebrow;
  final int itemCount;
  final int previewCount;
  final double spacing;
  final String seeAllLabel;
  final VoidCallback? onSeeAll;
  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);
    final canExpand = itemCount > previewCount;
    final visibleCount = expanded.value || !canExpand
        ? itemCount
        : previewCount.clamp(0, itemCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DfSectionHeader(
          title: title,
          eyebrow: eyebrow,
          action: canExpand
              ? () => expanded.value = !expanded.value
              : onSeeAll,
          actionLabel: canExpand
              ? (expanded.value ? 'Ver menos' : seeAllLabel)
              : (onSeeAll != null ? seeAllLabel : null),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < visibleCount; i++) ...[
          if (i > 0) SizedBox(height: spacing),
          itemBuilder(context, i),
        ],
      ],
    );
  }
}
