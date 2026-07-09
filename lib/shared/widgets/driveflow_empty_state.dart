import 'package:flutter/material.dart';

import 'design_system/df_empty_state.dart';

/// Estado vazio — delega para [DfEmptyState] (Design System v2).
@Deprecated('Use DfEmptyState. Será removido em v2.1.')
class DriveFlowEmptyState extends StatelessWidget {
  const DriveFlowEmptyState({
    required this.title,
    super.key,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DfEmptyState(title: title, subtitle: subtitle, icon: icon);
  }
}
