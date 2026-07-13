import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/services/home_widget_service.dart';
import '../../core/utils/value_visibility_provider.dart';
import '../../features/dashboard/presentation/providers/dashboard_providers.dart';
import '../../features/shift/presentation/providers/shift_session_providers.dart';

/// Atualiza widgets nativos (Android/iOS) quando o lucro do dia ou turno mudam.
class HomeWidgetBootstrap extends ConsumerWidget {
  const HomeWidgetBootstrap({required this.child, super.key});

  final Widget child;

  void _sync(WidgetRef ref) {
    final today = ref.read(dashboardTodayProvider).valueOrNull;
    if (today == null) return;
    final hidden = ref.read(valueVisibilityHiddenProvider);
    final session = ref.read(activeShiftSessionProvider).valueOrNull;
    final shiftSummary = ref.read(shiftSessionSummaryProvider);

    HomeWidgetService.syncToday(
      today: today,
      hideValues: hidden,
      shiftActive: session != null,
      shiftSummary: shiftSummary,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(dashboardTodayProvider, (_, __) => _sync(ref));
    ref.listen(valueVisibilityHiddenProvider, (_, __) => _sync(ref));
    ref.listen(activeShiftSessionProvider, (_, __) => _sync(ref));
    ref.listen(shiftSessionSummaryProvider, (_, __) => _sync(ref));

    return child;
  }
}
