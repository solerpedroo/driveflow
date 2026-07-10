import 'package:flutter/material.dart';

/// Copy e narrativa de produto — storytelling para vender valor e assinatura.
abstract final class ProductStory {
  static const tagline = 'Lucro claro. Decisão inteligente.';

  static const socialProofCount = '12.400+';
  static const socialProofLabel = 'motoristas já controlam lucro com DriveFlow';

  static const testimonial =
      '"Descobri que sexta 18h–22h rende 40% mais por hora."';

  static const proHeadline = 'DriveFlow Pro';
  static const proSubtitle =
      'Desbloqueie o cockpit completo — IA ilimitada, previsões e importação.';

  static const List<({String title, String body, IconData icon})> proFeatures = [
    (
      title: 'IA ilimitada',
      body: 'Pergunte o que quiser sobre lucro, metas e custos.',
      icon: Icons.auto_awesome_rounded,
    ),
    (
      title: 'Previsão de lucro',
      body: 'Saiba quanto pode faturar antes do mês acabar.',
      icon: Icons.trending_up_rounded,
    ),
    (
      title: 'Importação de extratos',
      body: 'Sincronize ganhos automaticamente em segundos.',
      icon: Icons.upload_file_rounded,
    ),
    (
      title: 'Apps conectados',
      body: 'Sync automático Uber, 99 e InDrive com analytics por app.',
      icon: Icons.hub_rounded,
    ),
    (
      title: 'Insights de horário',
      body: 'Descubra quando cada hora vale mais.',
      icon: Icons.schedule_rounded,
    ),
  ];

  static const List<({String headline, String subtitle})> splashSlides = [
    (
      headline: 'Lucro claro.\nDecisão inteligente.',
      subtitle:
          'Veja quanto você realmente ganha — depois de combustível, taxas e manutenção.',
    ),
    (
      headline: 'R\$ 248/dia\nem média',
      subtitle:
          'Motoristas que registram corridas descobrem custos ocultos e aumentam o lucro líquido.',
    ),
    (
      headline: 'IA que fala\ncom seus números',
      subtitle:
          'Pergunte sobre metas, horários e previsões — respostas com seus dados reais.',
    ),
  ];

  static const List<({String label, String detail, IconData icon})> authBenefits =
      [
    (
      label: 'Lucro por hora',
      detail: 'Saiba se cada corrida compensa',
      icon: Icons.speed_rounded,
    ),
    (
      label: 'Meta com anel',
      detail: 'Acompanhe o ritmo do dia em tempo real',
      icon: Icons.track_changes_rounded,
    ),
    (
      label: 'Insights de horário',
      detail: 'Descubra quando rodar vale mais',
      icon: Icons.insights_rounded,
    ),
  ];

  static const aiSampleQuestion = 'Quanto lucrei este mês?';
  static const aiSampleAnswer =
      'Você lucrou R\$ 4.320,00 este mês — 18% acima do mês passado. '
      'Seu melhor horário foi sexta 18h–22h (R\$ 42/h).';

  static const aiUpsell = 'Pro = IA ilimitada + previsões + importação de extratos';
}
