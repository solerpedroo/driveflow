import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/shift/data/datasources/shift_session_storage.dart';
import '../../features/shift/presentation/providers/shift_session_providers.dart';

/// Garante emissão inicial da sessão ativa após cold start.
class ShiftSessionBootstrap extends ConsumerStatefulWidget {
  const ShiftSessionBootstrap({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ShiftSessionBootstrap> createState() =>
      _ShiftSessionBootstrapState();
}

class _ShiftSessionBootstrapState extends ConsumerState<ShiftSessionBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShiftSessionStorage.emitCurrent();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(activeShiftSessionProvider);
    return widget.child;
  }
}
