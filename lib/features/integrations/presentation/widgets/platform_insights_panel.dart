import 'package:flutter/material.dart';

import 'platform_cockpit_panel.dart';

/// @deprecated Use [PlatformCockpitPanel] com abas Hoje · Turno · Comparativo.
@Deprecated('Use PlatformCockpitPanel')
class PlatformInsightsPanel extends StatelessWidget {
  const PlatformInsightsPanel({super.key});

  @override
  Widget build(BuildContext context) => const PlatformCockpitPanel();
}
