import 'package:flutter/material.dart';

/// Slide do onboarding de boas-vindas (padrão Mescla Invest).
class OnboardingSlide {
  const OnboardingSlide({
    required this.title,
    required this.body,
    required this.icon,
    this.accent,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color? accent;
}
