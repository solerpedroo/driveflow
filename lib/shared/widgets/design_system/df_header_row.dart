import 'package:flutter/material.dart';

import '../driveflow_brand_logo.dart';

/// Cabeçalho padrão das abas — logo DriveFlow + ação opcional (Mescla).
class DfHeaderRow extends StatelessWidget {
  const DfHeaderRow({
    super.key,
    this.trailing,
    this.showTagline = false,
  });

  final Widget? trailing;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DriveFlowBrandLogo(
          size: LogoSize.medium,
          showTagline: showTagline,
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}
