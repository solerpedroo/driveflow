import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/services/shift_live_presence_service.dart';
import '../../core/utils/value_visibility_provider.dart';
import '../../features/shift/presentation/providers/shift_session_providers.dart';

/// Mantém Live Activity / notificação ongoing sincronizada com o turno ativo.
class ShiftLivePresenceBootstrap extends ConsumerWidget {
  const ShiftLivePresenceBootstrap({required this.child, super.key});

  final Widget child;

  Future<void> _sync(WidgetRef ref) async {
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
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(activeShiftSessionProvider, (_, __) => _sync(ref));
    ref.listen(shiftSessionSummaryProvider, (_, __) => _sync(ref));
    ref.listen(valueVisibilityHiddenProvider, (_, __) => _sync(ref));

    return child;
  }
}
