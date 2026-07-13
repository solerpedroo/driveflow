import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/services/home_widget_service.dart';
import '../../core/utils/value_visibility_provider.dart';
import '../../features/dashboard/presentation/providers/dashboard_providers.dart';
import '../../features/shift/presentation/providers/shift_session_providers.dart';

/// Atualiza widgets nativos (Android/iOS) quando o lucro do dia ou turno mudam.
///
/// Debounce evita rajadas de I/O nativo a cada emit dos streams.
class HomeWidgetBootstrap extends ConsumerStatefulWidget {
  const HomeWidgetBootstrap({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<HomeWidgetBootstrap> createState() =>
      _HomeWidgetBootstrapState();
}

class _HomeWidgetBootstrapState extends ConsumerState<HomeWidgetBootstrap> {
  Timer? _debounce;
  static const _debounceDuration = Duration(milliseconds: 750);

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _scheduleSync() {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, _sync);
  }

  void _sync() {
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
  Widget build(BuildContext context) {
    ref.listen(dashboardTodayProvider, (_, __) => _scheduleSync());
    ref.listen(valueVisibilityHiddenProvider, (_, __) => _scheduleSync());
    ref.listen(activeShiftSessionProvider, (_, __) => _scheduleSync());
    ref.listen(shiftSessionSummaryProvider, (_, __) => _scheduleSync());

    return widget.child;
  }
}
