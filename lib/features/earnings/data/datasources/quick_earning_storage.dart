import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../../domain/entities/quick_earning_entry.dart';

/// Histórico local dos últimos ganhos rápidos (até 6 entradas).
abstract final class QuickEarningStorage {
  static const _key = 'quick_earning_history';
  static const _maxEntries = 6;

  static Box<dynamic> get _box => Hive.box<dynamic>(HiveBoxes.appState);

  static List<QuickEarningEntry> readHistory() {
    final raw = _box.get(_key);
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((item) => QuickEarningEntry.fromJson(Map<String, dynamic>.from(item)))
        .where((entry) => entry.amount > 0)
        .toList(growable: false);
  }

  static Future<void> remember({
    required RidePlatform platform,
    required double amount,
  }) async {
    final history = [
      QuickEarningEntry(
        platform: platform,
        amount: amount,
        usedAt: DateTime.now(),
      ),
      ...readHistory().where(
        (entry) =>
            entry.platform != platform ||
            (entry.amount - amount).abs() > 0.009,
      ),
    ].take(_maxEntries).toList(growable: false);

    await _box.put(
      _key,
      history.map((entry) => entry.toJson()).toList(growable: false),
    );
  }

  static Future<void> clear() => _box.delete(_key);
}
