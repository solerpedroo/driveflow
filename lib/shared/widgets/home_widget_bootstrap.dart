import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/services/home_widget_service.dart';
import '../../core/utils/value_visibility_provider.dart';
import '../../features/dashboard/presentation/providers/dashboard_providers.dart';

/// Atualiza o widget Android quando o lucro do dia muda.
class HomeWidgetBootstrap extends ConsumerWidget {
  const HomeWidgetBootstrap({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(dashboardTodayProvider, (previous, next) {
      next.whenData((today) {
        final hidden = ref.read(valueVisibilityHiddenProvider);
        HomeWidgetService.syncToday(today: today, hideValues: hidden);
      });
    });

    ref.listen(valueVisibilityHiddenProvider, (previous, next) {
      final today = ref.read(dashboardTodayProvider).valueOrNull;
      if (today == null) return;
      HomeWidgetService.syncToday(today: today, hideValues: next);
    });

    return child;
  }
}
