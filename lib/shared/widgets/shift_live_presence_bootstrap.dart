import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/services/shift_live_presence_service.dart';
import '../../core/utils/value_visibility_provider.dart';
import '../../features/shift/presentation/providers/shift_session_providers.dart';

/// Mantém Live Activity / notificação ongoing sincronizada com o turno ativo.
///
/// Debounce reduz custo de bridge nativo em aparelhos com pouca RAM.
class ShiftLivePresenceBootstrap extends ConsumerStatefulWidget {
  const ShiftLivePresenceBootstrap({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ShiftLivePresenceBootstrap> createState() =>
      _ShiftLivePresenceBootstrapState();
}

class _ShiftLivePresenceBootstrapState
    extends ConsumerState<ShiftLivePresenceBootstrap> {
  Timer? _debounce;
  static const _debounceDuration = Duration(milliseconds: 800);

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _scheduleSync() {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      unawaited(_sync());
    });
  }

  Future<void> _sync() async {
    final session = ref.read(activeShiftSessionProvider).valueOrNull;
    final summary = ref.read(shiftSessionSummaryProvider);
    final hidden = ref.read(valueVisibilityHiddenProvider);

    if (session == null || summary == null) {
      await ShiftLivePresenceService.clear();
      return;
    }

    await ShiftLivePresenceService.sync(
      session: session,
      summary: summary,
      hideValues: hidden,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(activeShiftSessionProvider, (_, __) => _scheduleSync());
    ref.listen(shiftSessionSummaryProvider, (_, __) => _scheduleSync());
    ref.listen(valueVisibilityHiddenProvider, (_, __) => _scheduleSync());

    return widget.child;
  }
}
