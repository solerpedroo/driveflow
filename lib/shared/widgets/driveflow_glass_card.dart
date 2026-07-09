import 'package:flutter/material.dart';

import 'design_system/df_card.dart';

/// Cartão glassmorphism — delega para [DfCard] (Design System v2).
@Deprecated('Use DfCard. Será removido em v2.1.')
class DriveFlowGlassCard extends StatelessWidget {
  const DriveFlowGlassCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DfCard(padding: padding, onTap: onTap, child: child);
  }
}
