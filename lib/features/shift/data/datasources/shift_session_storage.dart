import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/storage/hive_boxes.dart';
import '../../domain/entities/shift_session_entity.dart';

/// Armazenamento Hive da sessão de turno ativa.
abstract final class ShiftSessionStorage {
  static const _activeKey = 'active_shift_session';

  static Box<dynamic> get _box => Hive.box<dynamic>(HiveBoxes.shiftSessions);

  static final _controller = StreamController<ShiftSessionEntity?>.broadcast();

  static Stream<ShiftSessionEntity?> watchActive() => _controller.stream;

  static ShiftSessionEntity? readActive() {
    final raw = _box.get(_activeKey);
    if (raw is! Map) return null;
    final session = ShiftSessionEntity.fromJson(Map<String, dynamic>.from(raw));
    return session.status.isActiveLike ? session : null;
  }

  static Future<ShiftSessionEntity> saveActive(ShiftSessionEntity session) async {
    await _box.put(_activeKey, session.toJson());
    _controller.add(session);
    return session;
  }

  static Future<void> clearActive() async {
    await _box.delete(_activeKey);
    _controller.add(null);
  }

  static void emitCurrent() => _controller.add(readActive());
}
