import 'package:flutter/material.dart';

/// Copy de produto — narrativa clara para o motorista, sem planos ou jargão.
abstract final class ProductStory {
  static const tagline = 'Lucro claro. Decisão inteligente.';

  static const socialProofCount = '12.400+';
  static const socialProofLabel = 'motoristas já controlam lucro com DriveFlow';

  static const testimonial =
      '"Descobri que sexta 18h–22h rende 40% mais por hora."';

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

  static const aiHint =
      'Pergunte sobre lucro, metas, horários e previsões — tudo com seus dados.';

  static const proHeadline = 'Decisões de turno com dados reais';

  static const proDashboardSubtitle =
      'Sync automático, cockpit multi-app e relatórios Pro para rodar com mais lucro.';

  static const proProfileSubtitle =
      'Upgrade para sync em background, analytics por app e IA ilimitada.';

  static const proPaywallSubtitle =
      'Motoristas Pro economizam tempo e aumentam o lucro líquido com inteligência cross-platform.';

  static const proPriceLabel = 'R\$ 19,90/mês';

  static const proPriceDetail = '7 dias grátis · cancele quando quiser';

  static const proAiUpsell =
      'No Pro, perguntas ilimitadas com contexto de corridas e heatmap.';

  static const List<String> proFeatures = [
    'Sync automático Uber, 99 e InDrive',
    'Cockpit multi-app com heatmap e plano de turno',
    'Calendário de repasses e metas por app',
    'OCR ilimitado de comprovantes',
    'Relatório PDF visual por plataforma',
    'IA ilimitada com séries temporais',
  ];
}
