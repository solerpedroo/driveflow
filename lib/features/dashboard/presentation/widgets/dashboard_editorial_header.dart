import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/design_system/df_header_row.dart';

/// Topo da Início — só a marca. Privacidade fica no card de lucro.
class DashboardBrandBar extends StatelessWidget {
  const DashboardBrandBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const DfHeaderRow();
  }
}

/// Saudação abaixo da marca — Bom dia / Boa tarde / Boa noite.
class DashboardGreeting extends StatelessWidget {
  const DashboardGreeting({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Text(
      text,
      style: AppTypography.iosHeadline(brightness).copyWith(
        fontSize: 22,
        height: 1.2,
        letterSpacing: -0.4,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}
