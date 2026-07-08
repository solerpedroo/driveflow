import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goals_repository.dart';
import '../datasources/goals_remote_datasource.dart';
import '../mappers/goals_mapper.dart';

class GoalsRepositoryImpl implements GoalsRepository {
  GoalsRepositoryImpl({GoalsRemoteDataSource? remote})
      : _remote = remote ?? GoalsRemoteDataSource();

  final GoalsRemoteDataSource _remote;

  @override
  Stream<GoalEntity?> watchGoals() {
    return _remote.watchGoalsRow().map(
          (row) => row == null ? null : GoalsMapper.fromRow(row),
        );
  }

  @override
  Future<GoalEntity?> fetchGoals() async {
    final row = await _remote.fetchGoalsRow();
    if (row == null) return null;
    return GoalsMapper.fromRow(row);
  }

  @override
  Future<GoalEntity> upsertGoals(GoalDraft draft) async {
    final row = await _remote.upsertGoals(draft: draft);
    return GoalsMapper.fromRow(row);
  }
}
