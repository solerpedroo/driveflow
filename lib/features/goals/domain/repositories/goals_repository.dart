import '../entities/goal_entity.dart';

abstract interface class GoalsRepository {
  Stream<GoalEntity?> watchGoals();

  Future<GoalEntity?> fetchGoals();

  Future<GoalEntity> upsertGoals(GoalDraft draft);
}
