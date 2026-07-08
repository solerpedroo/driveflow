import '../../../../shared/domain/models/period_summary.dart';
import '../../../goals/domain/entities/goal_entity.dart';

/// Snapshot de relatório para um período selecionado.
class ReportSnapshot {
  const ReportSnapshot({
    required this.period,
    required this.summary,
    required this.generatedAt,
  });

  final GoalPeriod period;
  final PeriodSummary summary;
  final DateTime generatedAt;

  String get periodLabel => period.label;
}
