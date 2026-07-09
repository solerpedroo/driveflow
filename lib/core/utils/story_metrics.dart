import 'package:flutter/material.dart';

import '../../features/goals/domain/services/goal_progress_calculator.dart';
import '../../shared/domain/models/daily_profit_point.dart';
import '../../shared/domain/models/period_summary.dart';
import 'currency_formatter.dart';

/// Gera narrativas de produto a partir de métricas reais do motorista.
abstract final class StoryMetrics {
  static String heroSubtitle({
    required PeriodSummary today,
    required GoalProgress goalProgress,
    required List<DailyProfitPoint> weekProfits,
  }) {
    if (today.rides == 0 && today.revenue == 0) {
      return 'Registre sua primeira corrida e veja o lucro em tempo real';
    }

    if (goalProgress.hasTarget) {
      if (goalProgress.isComplete) {
        return 'Meta do dia batida — você está no controle do seu negócio';
      }
      return 'Faltam ${CurrencyFormatter.format(goalProgress.remainingAmount)} para bater sua meta de hoje';
    }

    final positiveDays =
        weekProfits.where((p) => p.profit > 0).map((p) => p.profit).toList();
    if (positiveDays.isNotEmpty && today.profit > 0) {
      final weekAvg =
          positiveDays.reduce((a, b) => a + b) / positiveDays.length;
      if (today.profit > weekAvg * 1.05) {
        final delta = today.profit - weekAvg;
        return '${CurrencyFormatter.format(delta)} acima da sua média semanal';
      }
    }

    if (today.profitPerHour != null && today.profitPerHour! > 0) {
      return 'Lucro de ${CurrencyFormatter.format(today.profitPerHour!)}/hora hoje — cada registro conta';
    }

    if (today.profit > 0) {
      return 'Continue registrando — insights e previsões ficam mais precisos';
    }

    return 'Cada corrida registrada alimenta insights e previsões com IA';
  }

  static List<StoryMetricCard> valueCards({
    required PeriodSummary today,
    required PeriodSummary month,
    required GoalProgress goalProgress,
  }) {
    final cards = <StoryMetricCard>[];

    if (today.profitPerHour != null && today.profitPerHour! > 0) {
      cards.add(StoryMetricCard(
        label: 'Lucro/hora hoje',
        value: CurrencyFormatter.format(today.profitPerHour!),
        narrative: 'Quanto cada hora na rua realmente rende',
        icon: Icons.speed_rounded,
        accent: const Color(0xFF34D399),
      ));
    }

    if (month.profit > 0) {
      cards.add(StoryMetricCard(
        label: 'Lucro no mês',
        value: CurrencyFormatter.formatSigned(month.profit),
        narrative: 'Seu resultado acumulado — o número que importa',
        icon: Icons.account_balance_wallet_rounded,
        accent: const Color(0xFF5BA4F5),
      ));
    }

    if (goalProgress.hasTarget) {
      cards.add(StoryMetricCard(
        label: 'Ritmo da meta',
        value: goalProgress.progressLabel,
        narrative: goalProgress.isComplete
            ? 'Meta atingida — mantenha o ritmo'
            : 'Faltam ${CurrencyFormatter.format(goalProgress.remainingAmount)}',
        icon: Icons.flag_rounded,
        accent: const Color(0xFFFBBF24),
      ));
    }

    if (today.rides > 0) {
      cards.add(StoryMetricCard(
        label: 'Corridas hoje',
        value: '${today.rides}',
        narrative: 'Cada corrida alimenta análises e insights',
        icon: Icons.local_taxi_rounded,
        accent: const Color(0xFF818CF8),
      ));
    }

    return cards;
  }
}

class StoryMetricCard {
  const StoryMetricCard({
    required this.label,
    required this.value,
    required this.narrative,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final String narrative;
  final IconData icon;
  final Color accent;
}
