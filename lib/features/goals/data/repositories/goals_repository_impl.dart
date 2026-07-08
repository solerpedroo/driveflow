import '../../../../core/storage/cached_remote_watch.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../../../../core/storage/local_entity_cache.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goals_repository.dart';
import '../datasources/goals_remote_datasource.dart';
import '../mappers/goals_mapper.dart';

class GoalsRepositoryImpl implements GoalsRepository {
  GoalsRepositoryImpl({
    GoalsRemoteDataSource? remote,
    LocalEntityCache? cache,
  })  : _remote = remote ?? GoalsRemoteDataSource(),
        _cache = cache ?? LocalEntityCache();

  final GoalsRemoteDataSource _remote;
  final LocalEntityCache _cache;

  @override
  Stream<GoalEntity?> watchGoals() {
    return watchCachedRemote<GoalEntity>(
      remote: _remote.watchGoalsRow().map(
            (row) => row == null ? const <Map<String, dynamic>>[] : [row],
          ),
      loadLocal: _loadLocal,
      mapRows: (rows) =>
          rows.map(GoalsMapper.fromRow).toList(growable: false),
      persistRemote: (rows) => _cache.replaceAll(HiveBoxes.goals, rows),
    ).map((items) => items.isEmpty ? null : items.first);
  }

  Future<List<GoalEntity>> _loadLocal() async {
    final rows = await _cache.readAll(HiveBoxes.goals);
    return rows.map(GoalsMapper.fromRow).toList(growable: false);
  }

  @override
  Future<GoalEntity?> fetchGoals() async {
    try {
      final row = await _remote.fetchGoalsRow();
      if (row != null) {
        await _cache.replaceAll(HiveBoxes.goals, [row]);
        return GoalsMapper.fromRow(row);
      }
      return null;
    } on Object {
      final local = await _loadLocal();
      return local.isEmpty ? null : local.first;
    }
  }

  @override
  Future<GoalEntity> upsertGoals(GoalDraft draft) async {
    final row = await _remote.upsertGoals(draft: draft);
    return GoalsMapper.fromRow(row);
  }
}
