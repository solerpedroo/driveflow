import '../entities/earning_entity.dart';
import '../repositories/earnings_repository.dart';

class WatchEarnings {
  const WatchEarnings(this._repository);

  final EarningsRepository _repository;

  Stream<List<EarningEntity>> call() => _repository.watchEarnings();
}

class CreateEarning {
  const CreateEarning(this._repository);

  final EarningsRepository _repository;

  Future<EarningEntity> call(EarningDraft draft) =>
      _repository.createEarning(draft);
}

class UpdateEarning {
  const UpdateEarning(this._repository);

  final EarningsRepository _repository;

  Future<EarningEntity> call({
    required String id,
    required EarningDraft draft,
  }) =>
      _repository.updateEarning(id: id, draft: draft);
}

class DeleteEarning {
  const DeleteEarning(this._repository);

  final EarningsRepository _repository;

  Future<void> call(String id) => _repository.deleteEarning(id);
}
