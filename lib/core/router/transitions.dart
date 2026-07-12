import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_motion.dart';
import '../theme/app_theme.dart';

/// Transições de rota empilhada (fade + micro-slide).
class DriveFlowFadeSlidePageRoute<T> extends MaterialPageRoute<T> {
  DriveFlowFadeSlidePageRoute({
    required super.builder,
    super.settings,
  });

  @override
  Duration get transitionDuration => DriveFlowMotion.normal;

  @override
  Duration get reverseTransitionDuration => DriveFlowMotion.fast;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _fadeSlideTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
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
  Duration get transitionDuration => DriveFlowMotion.normal;

  @override
  Duration get reverseTransitionDuration => DriveFlowMotion.fast;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _horizontalSlideTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
      slideFromRight: slideFromRight,
    );
  }
}

/// Fade suave — splash, shell e trocas sem empilhar “push”.
CustomTransitionPage<void> driveFlowFadePage({
  required LocalKey key,
  required Widget child,
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
      final secondary = CurvedAnimation(
        parent: secondaryAnimation,
        curve: DriveFlowMotion.exit,
      );
      return FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0.88).animate(secondary),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}

/// Fade + micro-slide — padrão para subpáginas empilhadas (formulários, histórico).
CustomTransitionPage<void> driveFlowFadeSlidePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: DriveFlowMotion.normal,
    reverseTransitionDuration: DriveFlowMotion.fast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return _fadeSlideTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: child,
      );
    },
  );
}

/// Slide horizontal — auth e etapas de onboarding.
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
      return _horizontalSlideTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: child,
        slideFromRight: slideFromRight,
      );
    },
  );
}

Widget _fadeSlideTransition({
  required Animation<double> animation,
  required Animation<double> secondaryAnimation,
  required Widget child,
}) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: DriveFlowMotion.enter,
    reverseCurve: DriveFlowMotion.exit,
  );
  final secondary = CurvedAnimation(
    parent: secondaryAnimation,
    curve: DriveFlowMotion.exit,
  );

  return SlideTransition(
    position: Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.04, 0),
    ).animate(secondary),
    child: FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.86).animate(secondary),
      child: FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.035, 0.02),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      ),
    ),
  );
}

Widget _horizontalSlideTransition({
  required Animation<double> animation,
  required Animation<double> secondaryAnimation,
  required Widget child,
  required bool slideFromRight,
}) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: DriveFlowMotion.enter,
    reverseCurve: DriveFlowMotion.exit,
  );
  final secondary = CurvedAnimation(
    parent: secondaryAnimation,
    curve: DriveFlowMotion.exit,
  );
  final begin = slideFromRight ? const Offset(1, 0) : const Offset(-0.35, 0);

  return SlideTransition(
    position: Tween<Offset>(
      begin: Offset.zero,
      end: Offset(slideFromRight ? -0.12 : 0.08, 0),
    ).animate(secondary),
    child: FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.9).animate(secondary),
      child: SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      ),
    ),
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
