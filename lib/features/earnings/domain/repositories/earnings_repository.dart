import '../entities/earning_entity.dart';

abstract interface class EarningsRepository {
  Stream<List<EarningEntity>> watchEarnings();

  Future<List<EarningEntity>> fetchEarnings();

  Future<EarningEntity> createEarning(EarningDraft draft);

  Future<EarningEntity> updateEarning({
    required String id,
    required EarningDraft draft,
  });

  Future<void> deleteEarning(String id);
}
