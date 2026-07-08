import '../../../../core/constants/date_range_period.dart';
import '../../../../core/utils/date_utils.dart';

/// Períodos de meta financeira do motorista.
enum GoalPeriod {
  daily('Diária', 'Hoje'),
  weekly('Semanal', 'Semana'),
  monthly('Mensal', 'Mês'),
  yearly('Anual', 'Ano');

  const GoalPeriod(this.label, this.shortLabel);

  final String label;
  final String shortLabel;
}

/// Metas de lucro configuradas pelo usuário (1 row por usuário).
class GoalEntity {
  const GoalEntity({
    required this.id,
    required this.userId,
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.yearly,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final double daily;
  final double weekly;
  final double monthly;
  final double yearly;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  double amountFor(GoalPeriod period) {
    switch (period) {
      case GoalPeriod.daily:
        return daily;
      case GoalPeriod.weekly:
        return weekly;
      case GoalPeriod.monthly:
        return monthly;
      case GoalPeriod.yearly:
        return yearly;
    }
  }

  GoalEntity copyWith({
    String? id,
    String? userId,
    double? daily,
    double? weekly,
    double? monthly,
    double? yearly,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      daily: daily ?? this.daily,
      weekly: weekly ?? this.weekly,
      monthly: monthly ?? this.monthly,
      yearly: yearly ?? this.yearly,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Valores editáveis das metas.
class GoalDraft {
  const GoalDraft({
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.yearly,
  });

  final double daily;
  final double weekly;
  final double monthly;
  final double yearly;
}

/// Resolve intervalo de datas para um [GoalPeriod].
DateRange dateRangeForGoalPeriod(GoalPeriod period, [DateTime? anchor]) {
  final now = anchor ?? DateTime.now();
  switch (period) {
    case GoalPeriod.daily:
      return DateRange(
        start: DateUtilsDriveFlow.startOfDay(now),
        end: DateUtilsDriveFlow.endOfDay(now),
      );
    case GoalPeriod.weekly:
      return DateRange(
        start: DateUtilsDriveFlow.startOfWeek(now),
        end: DateUtilsDriveFlow.endOfWeek(now),
      );
    case GoalPeriod.monthly:
      return DateRange(
        start: DateUtilsDriveFlow.startOfMonth(now),
        end: DateUtilsDriveFlow.endOfMonth(now),
      );
    case GoalPeriod.yearly:
      return DateRange(
        start: DateUtilsDriveFlow.startOfYear(now),
        end: DateUtilsDriveFlow.endOfYear(now),
      );
  }
}
