import '../../../../core/constants/date_range_period.dart';
import '../../../goals/domain/entities/goal_entity.dart';

/// Referência temporal para comparação de indicadores.
enum ComparisonReference {
  previousPeriod('Período anterior'),
  sameMonthLastYear('Mesmo mês, ano passado');

  const ComparisonReference(this.label);

  final String label;
}

/// Janela de tendência de lucro diário.
enum TrendWindow {
  days30(30, '30 dias'),
  days90(90, '90 dias');

  const TrendWindow(this.days, this.label);

  final int days;
  final String label;
}

/// Intervalo de comparação (atual + referência).
class ComparisonPeriods {
  const ComparisonPeriods({
    required this.period,
    required this.reference,
    required this.currentRange,
    required this.referenceRange,
  });

  final GoalPeriod period;
  final ComparisonReference reference;
  final DateRange currentRange;
  final DateRange referenceRange;
}
