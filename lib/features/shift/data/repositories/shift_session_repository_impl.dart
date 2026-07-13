import '../../domain/entities/shift_session_entity.dart';
import '../../domain/entities/shift_session_status.dart';
import '../../domain/repositories/shift_session_repository.dart';
import '../datasources/shift_session_storage.dart';

class ShiftSessionRepositoryImpl implements ShiftSessionRepository {
  @override
  ShiftSessionEntity? readActive() => ShiftSessionStorage.readActive();

  @override
  Stream<ShiftSessionEntity?> watchActive() => ShiftSessionStorage.watchActive();

  @override
  Future<ShiftSessionEntity> saveActive(ShiftSessionEntity session) {
    return ShiftSessionStorage.saveActive(session);
  }

  @override
  Future<void> clearActive() => ShiftSessionStorage.clearActive();

  @override
  Future<ShiftSessionEntity?> archiveCompleted(
    ShiftSessionEntity session,
  ) async {
    final completed = session.copyWith(
      status: ShiftSessionStatus.completed,
      endedAt: session.endedAt ?? DateTime.now(),
      clearPausedAt: true,
    );
    await ShiftSessionStorage.clearActive();
    return completed;
  }
}
