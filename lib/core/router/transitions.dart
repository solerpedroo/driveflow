import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Transições de rota empilhada (fade + micro-slide).
class DriveFlowFadeSlidePageRoute<T> extends MaterialPageRoute<T> {
  DriveFlowFadeSlidePageRoute({
    required super.builder,
    super.settings,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.025),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

/// Atalho para push com transição DriveFlow.
Future<T?> driveFlowPush<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(
    DriveFlowFadeSlidePageRoute(builder: (_) => page),
  );
}

PageTransitionsTheme get driveFlowStackTransitionsTheme =>
    driveFlowPageTransitionsTheme;
