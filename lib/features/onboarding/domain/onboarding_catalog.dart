import 'package:flutter/material.dart';

import '../../../core/constants/driver_type.dart';
import '../../../core/theme/app_colors.dart';
import 'entities/onboarding_slide.dart';

/// Conteúdo editorial do onboarding — varia por tipo de motorista.
abstract final class OnboardingCatalog {
  static List<OnboardingSlide> slidesFor(DriverType driverType) {
    return switch (driverType) {
      DriverType.taxi => _taxiSlides,
      DriverType.rideShare => _rideShareSlides,
    };
  }

  static final _rideShareSlides = [
    OnboardingSlide(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Seu lucro em um só lugar',
      body:
          'Registre ganhos de Uber, 99 e InDrive, acompanhe despesas e veja quanto sobra no fim do dia.',
      accent: AppColors.brandBlue,
    ),
    OnboardingSlide(
      icon: Icons.hub_outlined,
      title: 'Conecte seus apps',
      body:
          'Sincronize corridas automaticamente ou lance manualmente quando preferir. Você decide o nível de automação.',
      accent: AppColors.brandBlue,
    ),
    OnboardingSlide(
      icon: Icons.flag_outlined,
      title: 'Metas que fazem sentido',
      body:
          'Defina objetivos diários e mensais. O painel mostra progresso real com base nos seus números.',
      accent: AppColors.profitGreen,
    ),
    OnboardingSlide(
      icon: Icons.auto_awesome_outlined,
      title: 'IA com seus dados',
      body:
          'Pergunte sobre lucro, melhor horário e manutenção. O assistente usa suas corridas e custos reais.',
      accent: AppColors.brandBlue,
    ),
  ];

  static final _taxiSlides = [
    OnboardingSlide(
      icon: Icons.local_taxi_rounded,
      title: 'Feito para o taxista',
      body:
          'Controle corridas do taxímetro, bandeira e contratos em um painel simples — tudo manual, sem integrações.',
      accent: AppColors.brandBlue,
    ),
    OnboardingSlide(
      icon: Icons.edit_note_outlined,
      title: 'Registro rápido',
      body:
          'Anote cada corrida em segundos: valor, horário e canal. Sem depender de apps de transporte.',
      accent: AppColors.brandBlue,
    ),
    OnboardingSlide(
      icon: Icons.receipt_long_outlined,
      title: 'Custos sob controle',
      body:
          'Combustível, pedágio, lavagem e manutenção entram no cálculo do lucro líquido do seu táxi.',
      accent: AppColors.warningAmber,
    ),
    OnboardingSlide(
      icon: Icons.insights_outlined,
      title: 'Decisão com clareza',
      body:
          'Veja lucro por dia, por km e por hora. Relatórios pensados para quem vive da bandeira.',
      accent: AppColors.profitGreen,
    ),
  ];
}
