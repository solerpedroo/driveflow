import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_motion.dart';
import 'app_theme.dart';

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
      curve: DriveFlowMotion.enter,
      reverseCurve: DriveFlowMotion.exit,
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

/// Transição horizontal estilo Cupertino para fluxo auth (login ↔ cadastro).
class DriveFlowAuthSlidePageRoute<T> extends MaterialPageRoute<T> {
  DriveFlowAuthSlidePageRoute({
    required super.builder,
    super.settings,
    this.slideFromRight = true,
  });

  final bool slideFromRight;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: DriveFlowMotion.enter,
      reverseCurve: DriveFlowMotion.exit,
    );
    final begin = slideFromRight
        ? const Offset(1, 0)
        : const Offset(-0.35, 0);
    return SlideTransition(
      position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curved),
      child: FadeTransition(
        opacity: curved,
        child: child,
      ),
    );
  }
}

/// Página GoRouter com slide horizontal para auth.
CustomTransitionPage<void> driveFlowAuthSlidePage({
  required LocalKey key,
  required Widget child,
  bool slideFromRight = true,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: DriveFlowMotion.normal,
    reverseTransitionDuration: DriveFlowMotion.fast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: DriveFlowMotion.enter,
        reverseCurve: DriveFlowMotion.exit,
      );
      final begin = slideFromRight
          ? const Offset(1, 0)
          : const Offset(-0.35, 0);
      return SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}

/// Atalho para push com transição DriveFlow.
Future<T?> driveFlowPush<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(
    DriveFlowFadeSlidePageRoute(builder: (_) => page),
  );
}

PageTransitionsTheme get driveFlowStackTransitionsTheme =>
    driveFlowPageTransitionsTheme;
