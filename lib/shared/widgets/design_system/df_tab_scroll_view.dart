import 'package:flutter/material.dart';

import 'df_screen_body.dart';

/// Scroll padrão das abas — padding Mescla + gaps entre seções.
class DfTabScrollView extends StatelessWidget {
  const DfTabScrollView({
    required this.children,
    super.key,
    this.onRefresh,
    this.bottomPadding = 96,
  });

  final List<Widget> children;
  final Future<void> Function()? onRefresh;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth && constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        return SingleChildScrollView(
          physics: onRefresh != null
              ? const AlwaysScrollableScrollPhysics()
              : null,
          padding: DfScreenBody.padding.copyWith(bottom: bottomPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: width, maxWidth: width),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(height: DfScreenBody.sectionGap),
                  children[i],
                ],
              ],
            ),
          ),
        );
      },
    );

    if (onRefresh == null) return content;
    return RefreshIndicator(onRefresh: onRefresh!, child: content);
  }
}
