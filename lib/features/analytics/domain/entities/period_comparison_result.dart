import 'analytics_enums.dart';
import '../../../goals/domain/entities/goal_entity.dart';

/// Variação de um indicador entre dois períodos.
class PeriodMetricDelta {
  const PeriodMetricDelta({
    required this.label,
    required this.current,
    required this.previous,
    required this.delta,
    this.deltaPercent,
  });

  final String label;
  final double current;
  final double previous;
  final double delta;
  final double? deltaPercent;

  bool get improved {
    if (label.contains('Despesa') || label.contains('Combustível')) {
      return delta < 0;
    }
    return delta > 0;
  }
}

/// Resultado consolidado da comparação entre períodos.
class PeriodComparisonResult {
  const PeriodComparisonResult({
    required this.period,
    required this.reference,
    required this.metrics,
  });

  final GoalPeriod period;
  final ComparisonReference reference;
  final List<PeriodMetricDelta> metrics;
}
