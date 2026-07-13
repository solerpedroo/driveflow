import '../entities/shift_session_entity.dart';

/// Persistência da sessão de turno ativa.
abstract class ShiftSessionRepository {
  ShiftSessionEntity? readActive();

  Stream<ShiftSessionEntity?> watchActive();

  Future<ShiftSessionEntity> saveActive(ShiftSessionEntity session);

  Future<void> clearActive();

  Future<ShiftSessionEntity?> archiveCompleted(ShiftSessionEntity session);
}
