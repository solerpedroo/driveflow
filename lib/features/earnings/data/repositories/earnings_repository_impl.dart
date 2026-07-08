import '../../domain/entities/earning_entity.dart';
import '../../domain/repositories/earnings_repository.dart';
import '../datasources/earnings_remote_datasource.dart';
import '../mappers/earnings_mapper.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  EarningsRepositoryImpl({EarningsRemoteDataSource? remote})
      : _remote = remote ?? EarningsRemoteDataSource();

  final EarningsRemoteDataSource _remote;

  @override
  Stream<List<EarningEntity>> watchEarnings() {
    return _remote.watchEarnings().map(
          (rows) => rows.map(EarningsMapper.fromRow).toList(growable: false),
        );
  }

  @override
  Future<List<EarningEntity>> fetchEarnings() async {
    final rows = await _remote.fetchEarnings();
    return rows.map(EarningsMapper.fromRow).toList(growable: false);
  }

  @override
  Future<EarningEntity> createEarning(EarningDraft draft) async {
    final row = await _remote.createEarning(draft: draft);
    return EarningsMapper.fromRow(row);
  }

  @override
  Future<EarningEntity> updateEarning({
    required String id,
    required EarningDraft draft,
  }) async {
    final row = await _remote.updateEarning(id: id, draft: draft);
    return EarningsMapper.fromRow(row);
  }

  @override
  Future<void> deleteEarning(String id) => _remote.deleteEarning(id);
}
