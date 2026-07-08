import '../entities/goal_entity.dart';
import '../repositories/goals_repository.dart';

class WatchGoals {
  const WatchGoals(this._repository);

  final GoalsRepository _repository;

  Stream<GoalEntity?> call() => _repository.watchGoals();
}

class UpsertGoals {
  const UpsertGoals(this._repository);

  final GoalsRepository _repository;

  Future<GoalEntity> call(GoalDraft draft) => _repository.upsertGoals(draft);
}
