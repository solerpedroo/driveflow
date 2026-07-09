import 'package:flutter/material.dart';

import 'design_system/df_skeleton.dart';

/// Skeleton de lista — delega para [DfSkeleton] (Design System v2).
@Deprecated('Use DfSkeleton. Será removido em v2.1.')
class DriveFlowListSkeleton extends StatelessWidget {
  const DriveFlowListSkeleton({this.itemCount = 4, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return DfSkeleton(itemCount: itemCount);
  }
}
