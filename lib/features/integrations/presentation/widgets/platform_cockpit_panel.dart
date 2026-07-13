import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/platform_cockpit_tab.dart';
import '../providers/platform_cockpit_providers.dart';
import 'platform_cockpit_compare_tab.dart';
import 'platform_cockpit_shift_tab.dart';
import 'platform_cockpit_tab_bar.dart';
import 'platform_cockpit_today_tab.dart';

/// Painel principal do cockpit multi-app com abas Hoje · Turno · Comparativo.
class PlatformCockpitPanel extends ConsumerWidget {
  const PlatformCockpitPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(platformCockpitTabProvider);
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Cockpit',
          style: AppTypography.labelCaps(brightness),
        ),
        const SizedBox(height: AppSpacing.sm),
        const PlatformCockpitTabBar(),
        const SizedBox(height: AppSpacing.lg),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: KeyedSubtree(
            key: ValueKey(tab),
            child: switch (tab) {
              PlatformCockpitTab.today => const PlatformCockpitTodayTab(),
              PlatformCockpitTab.shift => const PlatformCockpitShiftTab(),
              PlatformCockpitTab.compare => const PlatformCockpitCompareTab(),
            },
          ),
        ),
      ],
    );
  }
}
