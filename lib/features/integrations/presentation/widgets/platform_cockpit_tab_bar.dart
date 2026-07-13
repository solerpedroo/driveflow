import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/platform_cockpit_tab.dart';
import '../providers/platform_cockpit_providers.dart';
import '../../../../shared/widgets/design_system/df_period_pill_chip.dart';

/// Seletor de abas do cockpit multi-app.
class PlatformCockpitTabBar extends ConsumerWidget {
  const PlatformCockpitTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(platformCockpitTabProvider);

    return DfPeriodPillRow<PlatformCockpitTab>(
      segments: PlatformCockpitTab.values,
      selected: selected,
      labelBuilder: (tab) => tab.label,
      onChanged: (tab) =>
          ref.read(platformCockpitTabProvider.notifier).state = tab,
    );
  }
}
