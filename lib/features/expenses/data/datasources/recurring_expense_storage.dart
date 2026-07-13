import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/storage/hive_boxes.dart';
import '../../domain/entities/recurring_expense_template.dart';

/// Persistência local dos templates de despesa recorrente.
abstract final class RecurringExpenseStorage {
  static const _key = 'recurring_expense_templates';

  static Box<dynamic> get _box => Hive.box<dynamic>(HiveBoxes.appState);

  static List<RecurringExpenseTemplate> readTemplates() {
    final raw = _box.get(_key);
    if (raw is! List || raw.isEmpty) {
      return RecurringExpenseTemplate.defaults();
    }

    final stored = raw
        .whereType<Map>()
        .map(
          (item) =>
              RecurringExpenseTemplate.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((template) => template.id.isNotEmpty)
        .toList(growable: false);

    if (stored.isEmpty) return RecurringExpenseTemplate.defaults();

    final byId = {for (final template in stored) template.id: template};
    return RecurringExpenseTemplate.defaults()
        .map((defaults) => byId[defaults.id] ?? defaults)
        .toList(growable: false);
  }

  static Future<void> saveTemplates(
    List<RecurringExpenseTemplate> templates,
  ) async {
    await _box.put(
      _key,
      templates.map((template) => template.toJson()).toList(growable: false),
    );
  }

  static Future<void> upsert(RecurringExpenseTemplate template) async {
    final templates = readTemplates()
        .map(
          (item) => item.id == template.id ? template : item,
        )
        .toList(growable: false);
    await saveTemplates(templates);
  }

  static Future<void> clear() => _box.delete(_key);
}
